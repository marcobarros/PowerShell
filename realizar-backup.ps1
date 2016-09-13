<#
Nome do script: realizar-backup.ps1
Autor: Marco Antonio de Barros <marcobarros@hotmail.com>
Data cria��o: 2015-01-01
Vers�o: 1.0
Descri��o: Script b�sico para exportar VMs e compactar
em algum local da rede (ou local).
SOs testados: Windows Server 2012R2 (ingl�s)
#>


# Neste exemplo eu n�o uso servidor autenticado, pois uso um relay interno 
# permitindo apenas alguns IPs mandarem, mas voc� pode utilizar autentica��o
# se quiser (ver Send-MailMessage).

$SmtpServer = "meuservidordee-mail.com.br"
$From = "e-mail@meudominio.com.br"
$To = "e-mail@meudominio.com.br"
$Port = "587"


# Vari�veis que utilizarei para controle do backup como local de origem e destino.

$Origem = "F:\Backup\NOMESERVIDOR"
$TestaCaminhoOrigem = Test-Path $Origem
$Destino = "\\SERVIDORDEBACKUP\F$\Backup\NOMEDOSERVIDOR.7z"
$TestaCaminhoDestino = Test-Path $Destino
$Cliente = "NOMEDOCLIENTE"
$Rotina = "$Cliente - NOMEDOSERVIDOR"
$VMName = "NOMEDOSERVIDOR"


# Momento onde � verificado a exist�ncia de algum arquivo de exporta��o
# existente, caso exista, o mesmo � apagado, caso n�o exista, a VM ser�
# exportada.

if ($TestaCaminhoOrigem -eq $true) {
    Try {
        del $Origem -Recurse -Force -ErrorAction Stop
    }
    Catch {
        Send-MailMessage -From $From -To $To -SmtpServer $SmtpServer `
            -Port $Port -Subject "$Rotina - Falha ao excluir a pasta de origem." `
            -Body "$Rotina - Falha ao excluir a pasta de origem."
        Break
    }
}


# Exporta m�quina virtual para poder ser compactada posteriormente. Caso
# haja algum problema na exporta��o, envia e-mail avisando.

Try {
    Export-VM $VMName -Path $Origem -ErrorAction Stop
}
Catch {
    Send-MailMessage -From $From -To $To -SmtpServer $SmtpServer `
        -Port $Port -Subject "$Rotina - Falha ao exportar VM." `
        -Body "$Rotina - Falha ao exportar VM."
    Break
}


# Momento onde � verificado a exist�ncia de algum arquivo de backup
# existente, caso exista, o mesmo � apagado, caso n�o exista, a VM ser�
# compactada no local de destino. Caso haja algum problema na
# exclus�o, um e-mail ser� enviado.

if ($TestaCaminhoDestino -eq $true) {
    Try {
        del $Destino -Recurse -Force -ErrorAction Stop
    }
    Catch {
        Send-MailMessage -From $From -To $To -SmtpServer $SmtpServer `
            -Port $Port -Subject "$Rotina - Falha ao excluir a pasta de destino." `
            -Body "$Rotina - Falha ao excluir a pasta de destino."
        Break
    }
}


# Compacta m�quina virtual no servidor remoto. Neste caso usei o 7zip,
# por�m voc� pode utilizar outros utilit�rios. Como fiz o script no
# Windows Server 2012R2 usando o PowerShell V4, n�o tinha outra op��o,
# mas no PowerShell V5 (Windows 10), voc� pode utilizar o comando:
# Compress-Archive. Caso haja algum problema na compacta��o,
# um e-mail ser� enviado.
    
Try {
    & 'C:\Program Files\7-Zip\7z.exe' a $Destino $Origem
}
Catch {
    Send-MailMessage -From $From -To $To -SmtpServer $SmtpServer `
        -Port $Port -Subject "$Rotina - Falha ao compactar VM." `
        -Body "$Rotina - Falha ao compactar VM."
    Break
}
