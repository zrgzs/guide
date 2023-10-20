$DIR=".\.deploy_git"
if((Test-Path $DIR) -eq "True")
{
    Remove-Item -Recurse -Force $DIR
    Write-Host $DIR "delete success"
}
hexo clean
hexo g
hexo d
