PREFIX?=/usr/local

CLI_INSTALL_DIR=$(PREFIX)/bin
CLI_INSTALL_NAME=waldo
CLI_SCRIPT=WaldoCLI.sh

.PHONY: install uninstall

install:
	@ install -d $(CLI_INSTALL_DIR)
	@ install $(CLI_SCRIPT) $(CLI_INSTALL_DIR)/$(CLI_INSTALL_NAME)
	@ echo "Installed executable '$(CLI_INSTALL_NAME)' in '$(CLI_INSTALL_DIR)'"

uninstall:
	@ rm -f $(CLI_INSTALL_DIR)/$(CLI_INSTALL_NAME)
	@ echo "Uninstalled executable '$(CLI_INSTALL_NAME)' from '$(CLI_INSTALL_DIR)'"
