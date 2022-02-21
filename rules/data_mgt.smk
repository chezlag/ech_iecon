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
        expand(config["out_data"] + "{iAuxData}.dta", iAuxData = AUX_DATA)

## ech_tgt:                 arma las ech compatibilizadas
rule ech_tgt:
    input:
        expand(config["out_data"] + "ech_{iECHyear}.dta", iECHyear = ECH_YEARLIST)

# --- Build Rules --- #

rule aux_data:
    input:
        script = config["src_data_mgt"] + "{iAuxData}.do"
    output:
        data_dta = config["out_data"] + "{iAuxData}.dta"
    log:
        default = "{iAuxData}.log",
        move = config["log"] + "data_mgt/{iAuxData}.log"
    shell:
        "{runStata} {input.script} && cp {log.default} {log.move} && rm {log.default}"
        
rule ech_iecon:
    input:
        script = config["src_data_mgt"] + "ech_main.do",
        specs = config["src_data_specs"] + "ech_{iECHyear}_specs.do"
    output:
        data = config["out_data"] + "ech_{iECHyear}.dta"
    log:
        default = "ech_{iECHyear}.log",
        move = config["log"] + "data_mgt/{iAuxData}.log"
    shell:
        # Script takes one parameter: year of survey to compatibilize
        "{runStata} {input.script} {iECHyear} && cp {log.default} {log.move} && rm {log.default}"