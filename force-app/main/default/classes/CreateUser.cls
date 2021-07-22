global class StandardUserHandler implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    private void handleUser(boolean create, User u, Map<String, String> attributes,
        String federationIdentifier, boolean isStandard) {
        if(create && attributes.containsKey('User.Username')) {
            u.Username = attributes.get('User.Username');
        }
        if(create) {
            if(attributes.containsKey('User.FederationIdentifier')) {
                u.FederationIdentifier = attributes.get('User.FederationIdentifier');
            } else {
                u.FederationIdentifier = federationIdentifier;
            }
        }
        if(attributes.containsKey('User.ProfileId')) {
            String profileId = attributes.get('User.ProfileId');
            Profile p = [SELECT Id FROM Profile WHERE Id=:profileId];
            u.ProfileId = p.Id;
        }
        if(attributes.containsKey('User.UserRoleId')) {
            String userRole = attributes.get('User.UserRoleId');
            UserRole r = [SELECT Id FROM UserRole WHERE Id=:userRole];
            u.UserRoleId = r.Id;
        }
        if(attributes.containsKey('User.Phone')) {
            u.Phone = attributes.get('User.Phone');
        }
        if(attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
        }
        if (attributes.containsKey('User.FirstName')) {
            u.FirstName = attributes.get('User.FirstName');
        }
        if (attributes.containsKey('FirstName')) {
            u.FirstName = attributes.get('FirstName');
        }
        if (attributes.containsKey('User.LastName')) {
            u.LastName = attributes.get('User.LastName');
        }
        if (attributes.containsKey('User.Title')) {
            u.Title = attributes.get('User.Title');
            String uid = UserInfo.getUserId();
            User currentUser = [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id =: uid];
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
                if (alias.length() > 5) {
                    alias = alias.substring(0, 5);
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
	//More attributes here - removed for length

        //Handle custom fields here

        if(!create) {
            update(u);
        }
    }

    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        if(communityId != null || portalId != null) {
            String account = handleAccount(create, u, attributes);
            handleContact(create, account, u, attributes);
            handleUser(create, u, attributes, federationIdentifier, false);
        } else {
            handleUser(create, u, attributes, federationIdentifier, true);
        }
    }

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = new User();
        handleJit(true, u, samlSsoProviderId, communityId, portalId,
            federationIdentifier, attributes, assertion);
        return u;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = [SELECT Id FROM User WHERE Id=:userId];
        handleJit(false, u, samlSsoProviderId, communityId, portalId,
            federationIdentifier, attributes, assertion);
    }
}