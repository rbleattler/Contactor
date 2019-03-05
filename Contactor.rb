class Contactor < Formula
	desc "Manage contacts from the command line via the macOS Contacts framework."
	homepage "https://github.com/kettle/Contactor"
	url "https://github.com/kettle/Contactor/releases/download/1.2.6/Contactor-1.2.6.tar.gz"
	sha256 "ccd787ed2e99c2d0d41444629a2044c32e43947378e5ab13ed8f472771ace65c"
	version "1.2.6"

	depends_on "curl"

	bottle :unneeded

	def install
		bin.install "Contactor"
	end
end
