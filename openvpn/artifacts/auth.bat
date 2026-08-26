@echo off
REM auth.bat - script de autenticacao para OpenVPN (auth-user-pass-verify ... via-file)
REM ATENCAO: este script aceita QUALQUER usuario e QUALQUER senha.
REM Use apenas em ambiente de TESTE, nunca em producao.
REM
REM O OpenVPN chama este script assim:
REM   auth.bat <caminho_do_arquivo_temporario>
REM onde o arquivo temporario contem 2 linhas: usuario (linha 1) e senha (linha 2).
REM Saida 0 = login aceito. Saida diferente de 0 = login recusado.

exit /b 0
