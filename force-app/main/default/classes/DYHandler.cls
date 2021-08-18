global class SSOUserHandler implements Auth.SamlJitHandler {

    private class JitException extends Exception {}
  
    private void handleUser(boolean create,
                            User u,
                            Map<String, String> attributes,
                            String federationIdentifier,
                            boolean isStandard) {
  
      if (create && attributes.containsKey('User.Username')) {
        u.Username = attributes.get('User.Username');
      }
      if (create) {
        if (attributes.containsKey('User.FederationIdentifier')) {
          u.FederationIdentifier = attributes.get('User.FederationIdentifier');
        } else {
          u.FederationIdentifier = federationIdentifier;
        }
      }
      if (attributes.containsKey('User.Email')) {
        u.Email = attributes.get('User.Email');
      }
      if (attributes.containsKey('User.FirstName')) {
        u.FirstName = attributes.get('User.FirstName');
      }
      if (attributes.containsKey('User.LastName')) {
        u.LastName = attributes.get('User.LastName');
      }
      if (attributes.containsKey('User.Title')) {
        u.Title = attributes.get('User.Title');
      }
      if (attributes.containsKey('User.Country')) {
        u.Country = attributes.get('User.Country');
      }
      if (attributes.containsKey('User.CommunityNickname')) {
        u.CommunityNickname = attributes.get('User.CommunityNickname');
      }
      if (attributes.containsKey('User.ReceivesAdminInfoEmails')) {
        String ReceivesAdminInfoEmailsVal =
          attributes.get('User.ReceivesAdminInfoEmails');
        u.ReceivesAdminInfoEmails =
          '1'.equals(ReceivesAdminInfoEmailsVal) ||
          Boolean.valueOf(ReceivesAdminInfoEmailsVal);
      }
      if (attributes.containsKey('User.ReceivesInfoEmails')) {
        String ReceivesInfoEmailsVal = attributes.get('User.ReceivesInfoEmails');
        u.ReceivesInfoEmails =
          '1'.equals(ReceivesInfoEmailsVal) ||
          Boolean.valueOf(ReceivesInfoEmailsVal);
      }
      String uid = UserInfo.getUserId();
      User currentUser =
        [
          SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey
          FROM User
          WHERE Id = :uid
        ];
      if (attributes.containsKey('User.LocaleSidKey')) {
        u.LocaleSidKey = attributes.get('User.LocaleSidKey');
      } else if (create) {
        u.LocaleSidKey = currentUser.LocaleSidKey;
      }
      if (attributes.containsKey('User.LanguageLocaleKey')) {
        u.LanguageLocaleKey = attributes.get('User.LanguageLocaleKey');
      } else if (create) {
        u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
      }
      if (attributes.containsKey('User.Alias')) {
        u.Alias = attributes.get('User.Alias');
      } else if (create) {
        String alias = '';
        if (u.FirstName == null) {
          alias = u.LastName;
        } else {
          alias = u.FirstName.charAt(0) + u.LastName;
        }
        if (alias.length() > 8) {
          alias = alias.substring(0, 8);
        }
        u.Alias = alias;
      }
      if (attributes.containsKey('User.TimeZoneSidKey')) {
        u.TimeZoneSidKey = attributes.get('User.TimeZoneSidKey');
      } else if (create) {
        u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
      }
      if (attributes.containsKey('User.EmailEncodingKey')) {
        u.EmailEncodingKey = attributes.get('User.EmailEncodingKey');
      } else if (create) {
        u.EmailEncodingKey = currentUser.EmailEncodingKey;
      }
      (!create) {
        update(u);
    } else {
        Insert u;
    }
}

//Handle JIT
private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map < String, String > attributes, String assertion) {
    handleUser(create, u, attributes, federationIdentifier);
}

//For New User
global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
    String federationIdentifier, Map < String, String > attributes, String assertion) {
    User u = new User();
    handleJit(true, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    return u;
}

//For Existing User
global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
    String federationIdentifier, Map < String, String > attributes, String assertion) {
    User u = [SELECT Id, FirstName, ContactId FROM User WHERE Id =: userId];
    handleJit(false, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
}
}
//llup2.0