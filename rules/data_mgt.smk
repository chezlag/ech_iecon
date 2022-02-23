# Rules: data-management
#
# Contributors: @lachlandeer, @julianlanger, @bergmul

# --- Dictionaries --- #

AUX_DATA = ["ipc_2006m12", "bpc"]
ECH_YEARLIST = glob_wildcards(config["src_data_specs"] + "ech_{fyear}_specs.do").fyear

# --- Target Rules --- #

## auxdata_tgt:             arma la base de ipc y bpc
rule auxdata_tgt:
    input:
        expand("out/data/{iAuxData}.dta", iAuxData = AUX_DATA),
        "out/data/afampe.dta"

## ech_tgt:                 arma las ech compatibilizadas
rule ech_tgt:
    input:
        expand("out/data/ech_{iECHyear}.dta", iECHyear = ECH_YEARLIST)

# --- Build Rules --- #

rule aux_data:
    input:
        script = config["src_data_mgt"] + "{iAuxData}.do",
        paths = "out/lib/global_paths.do"
    output:
        data_dta = "out/data/{iAuxData}.dta"
    shell:
        "{runStata} {input.script}"

rule afampe_data:
    input:
        script = config["src_data_mgt"] + "afampe.do"
    output:
        data = "out/data/afampe.dta"
    shell:
        "{runStata} {input.script}"
        
rule ech_build:
    input:
        script = config["src_data_mgt"] + "ech_main.do",
        specs = config["src_data_specs"] + "ech_{iECHyear}_specs.do",
        paths = "out/lib/global_paths.do",
        aux_data = ["out/data/ipc_2006m12.dta", "out/data/afampe.dta", "out/data/bpc.dta"]
    output:
        data = config["out_data"] + "ech_{iECHyear}.dta"
    shell:
        # Script takes one parameter: year of survey to compatibilize
        "{runStata} {input.script} {wildcards.iECHyear}"
