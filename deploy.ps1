# deploy.ps1 - Git commit, push, Flutter build and Firebase deploy

$commitMessage = Read-Host "Enter commit message"

Write-Output "Adding all files..."
git add .

Write-Output "Committing..."
git commit -m "$commitMessage"

Write-Output "Pushing to GitHub..."
git push -u origin

Write-Output "Building Flutter web app..."
flutter build web

Write-Output "Deploying to Firebase..."
firebase deploy
