.PHONY: deploy

deploy:
	@echo "Pick a choice for what to do:"
	@echo "1. Commit and push to GitHub"
	@echo "2. Re-deploy to Firebase"
	@echo "3. Commit, push, build, and deploy"
	@read -p "Choice (1/2/3): " option; \
	if [ "$$option" = "1" ] || [ "$$option" = "3" ]; then \
		read -p "Enter commit message: " msg; \
		echo "Adding changes..."; \
		git add .; \
		echo "Committing..."; \
		git commit -m "$$msg"; \
		echo "Pushing to GitHub..."; \
		git push -u origin; \
	fi; \
	if [ "$$option" = "2" ] || [ "$$option" = "3" ]; then \
		echo "Building Flutter web app..."; \
		flutter build web; \
		echo "Deploying to Firebase..."; \
		firebase deploy; \
		echo "Deployment complete!"; \
		echo "Visit https://randart-v1.web.app to see the live app."; \
	fi
