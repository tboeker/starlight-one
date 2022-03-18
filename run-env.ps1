$host.ui.RawUI.WindowTitle = 'starlight-one-env'

docker-compose up --detach
Write-Host "Environment UP"
Read-Host "Press key to shutdown"
docker-compose down --remove-orphans