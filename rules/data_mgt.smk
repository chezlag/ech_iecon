# Rules: data-management
#
# Contributors: @lachlandeer, @julianlanger, @bergmul

# --- Dictionaries --- #

AUX_DATA = ["ipc_2006m12", "bpc"]
YEARLIST = glob_wildcards(config["src_data_specs"] + "ech_{fyear}_specs.do").fyear
SUBSCRIPTS = glob_wildcards(config["src_lib"] + "{fname}.do").fname

# --- Target Rules --- #

## ech_tgt:                 arma las ech compatibilizadas
rule ech_tgt:
    input:
        expand("out/data/ech_{year}.dta", year = YEARLIST)

# --- Build Rules --- #

rule aux_data:
    input:
        script = config["src_data_mgt"] + "{auxdataset}.do",
        paths = "out/lib/global_paths.do"
    output:
        data_dta = "out/data/{auxdataset}.dta"
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
        subscripts = expand(config["src_lib"] + "{ss}.do", ss = SUBSCRIPTS),
        specs = config["src_data_specs"] + "ech_{year}.do",
        paths = "out/lib/global_paths.do",
        aux_data = expand("out/data/{auxdataset}.dta", auxdataset = AUX_DATA)
    output:
        data = config["out_data"] + "ech_{year}.dta"
    shell:
        # Script takes one parameter: year of survey to compatibilize
        "{runStata} {input.script} {wildcards.year}"
