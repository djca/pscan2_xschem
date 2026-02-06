import re
import sys
import os

def extract_from_sch(sch_path):
    """Parses a single .sch file and returns component params, text blocks, and root status."""
    if not os.path.exists(sch_path):
        return None

    with open(sch_path, 'r') as f:
        content = f.read()

    # Regex for instances
    inst_pattern = r'C \{(.*?)\}\s+.*?\s+.*?\s+.*?\s+.*?\s+\{(.*?)\}'
    instances = re.findall(inst_pattern, content)
    
    comp_params = []
    subcircuit_types = set()

    for sym_file, attr_str in instances:
        name_match = re.search(r'name=([^\s}]+)', attr_str)
        pval_match = re.search(r'value=([^\s}]+)', attr_str)
        model_match = re.search(r'model=([^\s}]+)', attr_str)
        
        if name_match and pval_match:
            model_val = model_match.group(1) if model_match else ""
            comp_params.append((name_match.group(1), pval_match.group(1), model_val))
        
        if sym_file and not any(p in sym_file for p in ['res.sym', 'ind.sym', 'gnd.sym', 'iopin.sym', 'jj.sym', 'psrc.sym', 'isrc.sym']):
            base_type = os.path.splitext(os.path.basename(sym_file))[0]
            subcircuit_types.add(base_type)

    def extract_block(block_type):
        pattern = fr'pscan_type={block_type}.*?body=\\?\{{(.*?)\\?\}}'
        match = re.search(pattern, content, re.DOTALL)
        if match:
            return match.group(1).strip().replace('\\n', '\n\t')
        return ""

    return {
        "params": comp_params,
        "global_p": extract_block("parameter"),
        "internal_b": extract_block("internal"),
        "rules_b": extract_block("rules"),
        "is_root": "is_root=True" in extract_block("design_info"),
        "subs": list(subcircuit_types)
    }

def sanitize_model(model_str):
    """Truncates model name before the first parenthesis. e.g., 'JJJ(JA,JB)' -> 'JJJ'"""
    if not model_str:
        return ""
    return model_str.split('(')[0].strip()

def scan_hierarchy(target_name, search_paths, visited=None, all_models=None):
    """Pass 1: Collect sanitized models from the entire hierarchy."""
    if visited is None: visited = set()
    if all_models is None: all_models = set()
    
    base_name = os.path.splitext(os.path.basename(target_name))[0]
    if base_name in visited: return all_models
    visited.add(base_name)

    sch_file = next((os.path.join(p, f"{base_name}.sch") for p in search_paths if os.path.exists(os.path.join(p, f"{base_name}.sch"))), None)
    if not sch_file: return all_models

    data = extract_from_sch(sch_file)
    for _, _, m in data["params"]:
        sanitized = sanitize_model(m)
        if sanitized:
            all_models.add(sanitized)
    
    for sub in data["subs"]:
        scan_hierarchy(sub, search_paths, visited, all_models)
    
    return all_models

def generate_hdl(target_name, output_dir, search_paths, all_models, visited=None, recursive=True):
    """Pass 2: Write the files using the all_models set for logic."""
    if visited is None: visited = set()
    base_name = os.path.splitext(os.path.basename(target_name))[0]
    if base_name in visited: return
    visited.add(base_name)

    sch_file = next((os.path.join(p, f"{base_name}.sch") for p in search_paths if os.path.exists(os.path.join(p, f"{base_name}.sch"))), None)

    print(sch_file)
    if not sch_file: return

    data = extract_from_sch(sch_file)
    hdl_path = os.path.join(output_dir, f"{base_name}.hdl")

    # print(all_models)
    with open(hdl_path, 'w') as f:
        # --- GLOBAL PARAMETERS (ROOT LOGIC) ---
        if data["is_root"]:
            f.write("PARAMETER\n")
            f.write(f"\tXI=1, XJ=1, XL=1, XR=1,")
            if data["global_p"]:
                f.write(f"{data['global_p']}")
            if any(value in all_models for value in {'JN','JJN'}):
                f.write(",\n\tRSJN_VG=1, RSJN_N=1")
            if any(value in all_models for value in {'JT','JJT'}):
                f.write(",\n\tWBC=1, WVG=4.13, WVRAT=0.6, WRRAT=0.1")
            f.write(";\n\n")

        f.write(f"circuit {base_name}()\n{{\n")

        # --- LOCAL PARAMETERS ---
        param_strings = []
        for n, v, m in data["params"]:
            param_strings.append(f"\t{n}={v}")
            if n[0].upper() == 'J' and m == 'JJJ':
                param_strings.append(f"\tV{n}=1")
        if param_strings:
            f.write("\nPARAMETER\n" + ",\n".join(param_strings) + ";\n")

        if data["internal_b"]:
            f.write(f"\nINTERNAL\n\t{data['internal_b']};\n")

        # --- EXTERNAL BLOCK ---
        x_vars = [f"\tX{n}=1" for n, v, m in data["params"] 
                  if n[0].upper() == 'J' or 
                  (n[0].upper() in 'LIR' and m in [n[0].upper(), n[0].upper()+'?'])]
        if x_vars:
            f.write("\nEXTERNAL\n" + ",\n".join(x_vars) + ";\n")

        if data["rules_b"]:
            f.write(f"\n\t{data['rules_b']}\n")

        f.write("\n}")

    if recursive:
        for sub in data["subs"]:
            generate_hdl(sub, output_dir, search_paths, all_models, visited, recursive)

if __name__ == "__main__":
    target = sys.argv[1] 
    out_dir = sys.argv[2] 
    is_recursive = True
    if len(sys.argv) > 2:
        if sys.argv[2] == "single":
            is_recursive = False
    
    if not os.path.exists(out_dir): os.makedirs(out_dir)

    SEARCH_PATHS = [os.getcwd()] + [
        os.path.expanduser(p)
        for p in os.environ.get("XSCHEM_LIBRARY_PATH", "").split(":")
        if p
    ]

    # STEP 1: Scan everything to find all models
    hierarchy_models = scan_hierarchy(target, SEARCH_PATHS)

    # STEP 2: Generate HDL files with that knowledge
    generate_hdl(target, out_dir, SEARCH_PATHS, hierarchy_models, recursive=is_recursive)
