global class JITHandler implements Auth.SamlJitHandler  {
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map < String, String > attributes, String assertion) {
            
            String country = attributes.get('country');

            String displayName = attributes.get('displayName');
            List<String> displayNameParts = displayName.split(', ');

            JITCountryAttributeMapping__mdt cam = [SELECT Id, LocaleSidKey__c, TimeZoneSidKey__c, CurrencyIsoCode__c, LanguageLocaleKey__c, EmailEncodingKey__c 
                                                      FROM JITCountryAttributeMapping__mdt 
                                                      WHERE Country__c =:country];

            User u = new User();
            String username = attributes.get('email');
            u.username = username;
            u.FederationIdentifier = federationIdentifier;
            
            u.FirstName = displayNameParts[1];
            u.LastName = displayNameParts[0];
            u.Title = attributes.get('title');
            u.Country = country;
            u.Alias = (u.FirstName+''+u.LastName).substring(0,7);
            u.TimeZoneSidKey = cam.TimeZoneSidKey__c;
            u.EmailEncodingKey = cam.EmailEncodingKey__c;
            u.LocaleSidKey = cam.LocaleSidKey__c;
            u.LanguageLocaleKey = cam.LanguageLocaleKey__c;
            u.Email = attributes.get('email');
            String profileName = 'Standard User';
            Profile p = [SELECT Id FROM profile WHERE name =:profileName LIMIT 1];
            u.profileId = p.Id;
            u.IsActive = true;
            
            insert u;

            assignPermissionSetGroup(attributes.get('jobcode'), u.Id);

            return u;
        }

    @future
    public static void assignPermissionSetGroup (String jobCode, String userId){
        
        JITPermissionMapping__mdt psgMapping = [SELECT Id, PermissionSetGroup__c
                                            FROM JITPermissionMapping__mdt 
                                            WHERE JobCode__c =:jobCode];
        
        PermissionSetGroup  psg = [SELECT Id
                                   FROM PermissionSetGroup
                                   WHERE DeveloperName =:psgMapping.PermissionSetGroup__c];


          //Assign permission set group to user  
          PermissionSetAssignment psa = new PermissionSetAssignment(
              PermissionSetId = psg.Id,
              AssigneeId = userId
          );

          insert psa;
    }


    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
                          String federationIdentifier, Map < String, String > attributes, String assertion){
        User u = [SELECT Id, JobCode__c FROM User WHERE Id=:userId];
        
        assignPermissionSetGroup(attributes.get('jobcode'), u.Id);
    
    }
}