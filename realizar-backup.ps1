<#
Nome do script: realizar-backup.ps1
Autor: Marco Antonio de Barros <marcobarros@hotmail.com>
Data criação: 2015-01-01
Versão: 1.0
Descrição: Script básico para exportar VMs e compactar
em algum local da rede (ou local).
SOs testados: Windows Server 2012R2 (inglês)
#>


# Neste exemplo eu não uso servidor autenticado, pois uso um relay interno 
# permitindo apenas alguns IPs mandarem, mas você pode utilizar autenticação
# se quiser (ver Send-MailMessage).

$SmtpServer = "meuservidordee-mail.com.br"
$From = "e-mail@meudominio.com.br"
$To = "e-mail@meudominio.com.br"
$Port = "587"


# Variáveis que utilizarei para controle do backup como local de origem e destino.

$Origem = "F:\Backup\NOMESERVIDOR"
$TestaCaminhoOrigem = Test-Path $Origem
$Destino = "\\SERVIDORDEBACKUP\F$\Backup\NOMEDOSERVIDOR.7z"
$TestaCaminhoDestino = Test-Path $Destino
$Cliente = "NOMEDOCLIENTE"
$Rotina = "$Cliente - NOMEDOSERVIDOR"
$VMName = "NOMEDOSERVIDOR"


# Momento onde é verificado a existência de algum arquivo de exportação
# existente, caso exista, o mesmo é apagado, caso não exista, a VM será
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


# Exporta máquina virtual para poder ser compactada posteriormente. Caso
# haja algum problema na exportação, envia e-mail avisando.

Try {
    Export-VM $VMName -Path $Origem -ErrorAction Stop
}
Catch {
    Send-MailMessage -From $From -To $To -SmtpServer $SmtpServer `
        -Port $Port -Subject "$Rotina - Falha ao exportar VM." `
        -Body "$Rotina - Falha ao exportar VM."
    Break
}


# Momento onde é verificado a existência de algum arquivo de backup
# existente, caso exista, o mesmo é apagado, caso não exista, a VM será
# compactada no local de destino. Caso haja algum problema na
# exclusão, um e-mail será enviado.

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


# Compacta máquina virtual no servidor remoto. Neste caso usei o 7zip,
# porém você pode utilizar outros utilitários. Como fiz o script no
# Windows Server 2012R2 usando o PowerShell V4, não tinha outra opção,
# mas no PowerShell V5 (Windows 10), você pode utilizar o comando:
# Compress-Archive. Caso haja algum problema na compactação,
# um e-mail será enviado.
    
Try {
    & 'C:\Program Files\7-Zip\7z.exe' a $Destino $Origem
}
Catch {
    Send-MailMessage -From $From -To $To -SmtpServer $SmtpServer `
        -Port $Port -Subject "$Rotina - Falha ao compactar VM." `
        -Body "$Rotina - Falha ao compactar VM."
    Break
}
