# Makefile to git commit, push, build Flutter web, and deploy to Firebase

.PHONY: deploy

deploy:
	@read -p "Enter commit message: " msg; \
	echo "Adding changes..."; \
	git add .; \
	echo "Committing..."; \
	git commit -m "$$msg"; \
	echo "Pushing to GitHub..."; \
	git push -u origin; \
	echo "Building Flutter web app..."; \
	flutter build web; \
	echo "Deploying to Firebase..."; \
	firebase deploy
	@echo "Deployment complete!"
	@echo "Visit https://randart-v1.web.app to see the live app."	