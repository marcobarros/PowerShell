<#
Nome do script: auditar-arquivos.ps1
Autor: Marco Antonio de Barros <marcobarros@hotmail.com>
Data criacao: 2016-12-01
Versao: 1.0
Descricao: Script basico para pesquisar arquivos por data de acesso.
SOs testados: Windows 10 Enterprise (ingles)
#>
function AuditarArquivos {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$PadraoPesquisa,
        [Parameter(Mandatory=$true)]
        [string]$DataPesquisa
    )    
        
    foreach ($x in (dir $PadraoPesquisa -Recurse)) {
        if (($x.LastAccessTime).ToString() -match $DataPesquisa) {
            echo $x.DirectoryName $x.name; $y=($x.LastAccessTime).ToString(); $y
        }
    }
}

AuditarArquivos -PadraoPesquisa "c:\users\*.pdf" -DataPesquisa "01/2017"