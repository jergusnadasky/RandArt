# deploy.ps1 - Git commit, push, Flutter build and Firebase deploy

Write-Output "Pick a choice for what to do:"
Write-Output "1. Commit and push to GitHub"
Write-Output "2. Re-deploy to Firebase"
Write-Output "3. Commit, push, build, and deploy"

$userOption = Read-Host "Choice: (1/2/3)"

if ($userOption -eq "1" -or $userOption -eq "3") {
    $commitMessage = Read-Host "Enter commit message"
    
    Write-Output "Adding all files..."
    git add .

    Write-Output "Committing..."
    git commit -m "$commitMessage"

    Write-Output "Pushing to GitHub..."
    git push -u origin
}

if ($userOption -eq "2" -or $userOption -eq "3") {
    Write-Output "Building Flutter web app..."
    flutter build web

    Write-Output "Deploying to Firebase..."
    firebase deploy
}
