# Rules: data-management
#
# Contributors: @lachlandeer, @julianlanger, @bergmul

# --- Dictionaries --- #

AUX_DATA = ["ipc_2006m12"]

# --- Target Rules --- #

## auxdata_tgt:             arma la base de bfc y bpc
rule auxdata_tgt:
    input:
        expand(config["out_data"] + "{iAuxData}.dta", iAuxData = AUX_DATA)

# --- Build Rules --- #

rule aux_data:
    input:
        script = config["src_data_mgt"] + "{iAuxData}.do",
        paths = config["out_lib"] + "global_paths.do"
    output:
        data_dta = config["out_data"] + "{iAuxData}.dta"
    log:
        default = "{iAuxData}.log",
        move = config["log"] + "data_mgt/{iAuxData}.log"
    shell:
        "{runStata} {input.script} && cp {log.default} {log.move} && rm {log.default}"
        