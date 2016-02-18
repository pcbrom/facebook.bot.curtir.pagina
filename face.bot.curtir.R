##################################################################################
# APLICATIVO DE PARABENS NO FACEBOOK
# AUTOR: PEDRO CARVALHO BROM
# EMAIL: supermetrica@gmail.com
# FACEBOOK: www.facebook.com/pedraodeexatas
# PAGINA NO FACEBOOK: www.facebook.com/supermetrica
# CV LATTES: lattes.cnpq.br/0154064396756002
# GITHUB: https://github.com/pcbrom
##################################################################################

##################################################################################
# PREPARAR A LISTA DE AMIGOS
##################################################################################

# AQUI UTILIZAMOS A LISTA DE AMIGOS QUE O FACEBOOK OFERECE PARA DOWNLOAD
# CAMINHO: "Configuracoes" -> "Baixe uma cópia dos seus dados do Facebook."
arquivo.url = "AONDE_VC_BAIXOU_O_ARQUIVO"

# FUNCAO PARA EXTRAIR LISTA DE AMIGOS
amigos.f = function(arquivo.url) {
   apoio = readLines(arquivo.url, warn = F, encoding = "UTF-8")
   apoio = htmlParse(apoio, asText = TRUE, encoding = "UTF-8")
   node.apoio = xmlRoot(apoio)
   apoio = xpathSApply(node.apoio, "//li", xmlValue, encoding = "UTF-8")
   apoio = apoio[-c(1:16)] # removendo elementos que extraidos que nao queremos
   apoio = gsub(" \\(.*", "", apoio)
   apoio = unique(apoio)
   return (apoio)
}

# LISTA DE AMIGOS PRONTA
amigos = amigos.f(arquivo.url = arquivo.url)

##################################################################################
# INICIALIZACAO, WEBDRIVER E CARREGAR O QUE FOR NECESSARIO
##################################################################################

# LIMPAR MEMORIA DO R
rm(list=ls(all=T))

# DEFINIR PASTA DE TRABALHO Crtl + Shift + H
setwd("SUA_PASTA_DE_TRABALHO")

# INSTALAR E INVOCAR A BIBLIOTECA
require(RSelenium)

# VERIFICAR O SERVIDOR E BAIXAR SE NECESSARIO
#RSelenium::checkForServer()

# INICIAR O SERVIDOR
RSelenium::startServer()

# AJUSTAR O WEBDRIVER
remDr = remoteDriver(browserName = "firefox"); Sys.sleep(1)

# NAVEGACAO
remDr$open(silent = T); Sys.sleep(5)

# IR ATE A URL
url = 'https://www.facebook.com/'; remDr$sendKeysToActiveElement(list(url, key = "enter")); Sys.sleep(5)

##################################################################################
# LOGIN
##################################################################################

# ENCONTRAR O ELEMENTO 'EMAIL'
email = "SEU_EM@IL"
webElem = remDr$findElement(using = 'xpath', "//input[@id='email']")$sendKeysToElement(list(email))
Sys.sleep(1)

# ENCONTRAR O ELEMENTO 'PASS'
senha = "SUA_SENHA"
webElem = remDr$findElement(using = 'xpath', "//input[@id='pass']")$sendKeysToElement(list(senha))
Sys.sleep(1)

# ENCONTRAR O 'LOGINBUTTON'
webElem = remDr$findElement(using = 'xpath', "//label[@id='loginbutton']")$clickElement()
Sys.sleep(3)

##################################################################################
# PAGINA DE INTERESSE
##################################################################################

# IR ATE A PAGINA DE INTERESSE
url = 'https://www.facebook.com/supermetrica' # inserir a pagina de interesse para convite
webElem = remDr$navigate(url)
Sys.sleep(3)

# ENCONTRAR O ELEMENTO: CONVIDAR AMIGOS PARA CURTIR ESTA PAGINA
webElem = remDr$findElement(using = 'xpath', "//a[@id='js_12']")$clickElement() # este elemento js_12 deve ser revisto a cada login
webElem = remDr$findElement(using = 'xpath', "//span[contains(., 'Aumente seu público convidando seus amigos')]")$clickElement()

##################################################################################
# CONVIDAR O AMIGO PARA CURTIR A PAGINA
##################################################################################

# ENVIANDO O CONVITE
total.envios = length(amigos)

for (i in 1:total.envios) {
  res = try ({
    webElem = remDr$findElement(using = 'xpath', "//input[@id='u_3n_w']")
    webElem$clickElement()
    webElem$clearElement()
    webElem$sendKeysToElement(list(amigos[i]))
    webElem = remDr$findElement(using = 'xpath', "//span[@class='uiButtonText']")$clickElement()
  }); if (inherits(res,"try-error")) {next}; Sys.sleep(1)
}

##################################################################################
# FECHAR O PROGRAMA
##################################################################################
remDr$close()
remDr$closeServer()
