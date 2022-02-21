# Rules: data-management
#
# Contributors: @lachlandeer, @julianlanger, @bergmul

# --- Dictionaries --- #

AUX_DATA = ["ipc_2006m12", "bpc"]
ECH_IECON = glob_wildcards(config["src_data_mgt"] + "ech_{fyear}.do").fyear

# --- Target Rules --- #

## auxdata_tgt:             arma la base de ipc y bpc
rule auxdata_tgt:
    input:
        expand(config["out_data"] + "{iAuxData}.dta", iAuxData = AUX_DATA)

## ech_tgt:                 arma las ech compatibilizadas
rule ech_tgt:
    input:
        expand(config["out_data"] + "ech_{iECHyear}.dta", iECHyear = ECH_IECON)

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
        script = config["src_data_mgt"] + "ech_{iECHyear}.do"
    output:
        data = config["out_data"] + "ech_{iECHyear}.dta"
    log:
        default = "ech_{iECHyear}.log",
        move = config["log"] + "data_mgt/{iAuxData}.log"