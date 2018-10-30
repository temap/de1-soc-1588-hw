include settings.mk

ASSIGNMENT_FILES = $(PROJECT).qpf $(PROJECT).qsf
all: smart.log $(PROJECT).asm.rpt $(PROJECT).sta.rpt

clean: clean-quartus clean-qsys

clean-quartus:
	rm -rf db hps_isw_handoff incremental_db soc_system.sld \
	c5_pin_model_dump.txt hps_sdram_p0_summary.csv \
	*.jdi *.chg *.rpt *.chg smart.log *.htm *.eqn *.pin *.sof *.rbf *.pof *.summary *.smsg

clean-qsys:
	rm -rf $(QSYS_OUT) $(QSYS_PROJECT) $(QSYS_PROJECT).sopcinfo

qsys: $(QSYS_OUT)
map: smart.log $(PROJECT).map.rpt
fit: smart.log $(PROJECT).fit.rpt
asm: smart.log $(PROJECT).asm.rpt
sta: smart.log $(PROJECT).sta.rpt
smart: smart.log

update-mif: smart.log update_mif $(PROJECT).asm.rpt

QSYS_ARGS = --synthesis=VERILOG
MAP_ARGS =
FIT_ARGS =
ASM_ARGS =
STA_ARGS =

STAMP = echo done >

$(QSYS_OUT): $(QSYS_PROJECT).qsys
	qsys-generate $(QSYS_PROJECT).qsys $(QSYS_ARGS)

$(PROJECT).map.rpt: map.chg $(SOURCE_FILES)
	quartus_map $(MAP_ARGS) $(PROJECT)
	$(STAMP) fit.chg

$(PROJECT).fit.rpt: fit.chg $(PROJECT).map.rpt
	quartus_fit $(FIT_ARGS) $(PROJECT)
	$(STAMP) asm.chg
	$(STAMP) sta.chg

$(PROJECT).asm.rpt: asm.chg $(PROJECT).fit.rpt
	quartus_asm $(ASM_ARGS) $(PROJECT)

$(PROJECT).sta.rpt: sta.chg $(PROJECT).fit.rpt
	quartus_sta $(STA_ARGS) $(PROJECT)

smart.log: $(ASSIGNMENT_FILES)
	quartus_sh --determine_smart_action $(PROJECT) > smart.log

update_mif:
	quartus_cdb $(PROJECT) --update_mif
	$(STAMP) asm.chg

$(ASSIGNMENT_FILES):
	quartus_sh --prepare $(PROJECT)

map.chg:
	$(STAMP) map.chg
fit.chg:
	$(STAMP) fit.chg
sta.chg:
	$(STAMP) sta.chg
asm.chg:
	$(STAMP) asm.chg

$(PROJECT).rbf: $(PROJECT).sof
	quartus_cpf -c $(PROJECT).sof $(PROJECT).rbf

