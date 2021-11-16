# repo_viewer
This is a Flutter app that displays user's starred repositories.

In order to use it, you should change the content of lib/auth/infrastructure/github_authenticator.dart file and put your client id and secret there.
You should change these lines:

'''
  static const clientId = 'XXXXXXXXXXXX';
  static const clientSecret = 'XXXXXXXXXXXXXXXXX';
'''

In order to get client id and secret, you should generate them on Settings page of your Github account.
