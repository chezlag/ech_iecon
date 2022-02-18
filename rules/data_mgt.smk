# Rules: data-management
#
# Contributors: @lachlandeer, @julianlanger, @bergmul

# --- Dictionaries --- #
ECH_IECON = glob_wildcards(config["src_data"] + "ech_iecon/{fname}.dta").fname
BPS = ["bpc", "bfc"]

# --- Target Rules --- #

## bps_tgt:             arma la base de bfc y bpc
rule bps_tgt:
    input:
        expand(config["out_data"] + "{iBPS}.dta", iBPS = BPS)

# --- Build Rules --- #

rule vars_bps:
    input:
        script = config["src_data_mgt"] + "{iBPS}.do"
    output:
        data_dta = config["out_data"] + "{iBPS}.dta"
    log:
        default = "{iBPS}.log",
        move = config["log"] + "data_mgt/{iBPS}.log"
    shell:
        "{runStata} {input.script} && cp {log.default} {log.move} && rm {log.default}"
        