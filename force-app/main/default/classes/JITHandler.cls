global class JitHandler implements Auth.SamlJitHandler {
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map < String, String > attributes, String assertion) {
            
            String country = attributes['country'];

            String displayName = attributes['displayName'];
            List<String> displayNameParts = displayName.split(', ');

            JIT_Country_Attribute_Mapping__mdt cam = [SELECT Id, LocaleSidKey__c, TimeZoneSidKey__c, CurrencyIsoCode__c, LanguageLocaleKey__c, EmailEncodingKey__c 
                                                      FROM JIT_Country_Attribute_Mapping__mdt 
                                                      WHERE Country__c =:country];

            User u = new User();
            String username = attributes['email'];
            u.username = username;
            u.FederationIdentifier = federationIdentifier;
            
            u.FirstName = displayNameParts[1];
            u.LastName = displayNameParts[0];
            u.Title = attributes['title'];
            u.JobCode__c = attributes['jobcode'];
            u.Country = country;
            u.Alias = 'Test';
            u.CurrencyIsoCode = cam.CurrencyIsoCode__c;
            u.TimeZoneSidKey = cam.TimeZoneSidKey__c;
            u.EmailEncodingKey = cam.EmailEncodingKey__c;
            u.LocaleSidKey = cam.LocaleSidKey__c;
            u.LanguageLocaleKey = cam.LanguageLocaleKey__c;
            u.Email = attributes['email'];
            String profileName = 'Standard User';
            Profile p = [SELECT Id FROM profile WHERE name =:profileName LIMIT 1];
            u.profileId = p.Id;
            u.IsActive = true;
            
            insert u;

            assignPermissionSetGroup(attributes['jobcode'], u);

            return u;
        }

    @future
    public static void assignPermissionSetGroup (String jobCode, User u){
        
        JitPermissionMapping__mdt psgMapping = [SELECT Id, PermissionSetGroup__c
                                            FROM JitPermissionMapping__mdt 
                                            WHERE JobCode__c =:jobCode];
        
        PermissionSetGroup  psg = [SELECT Id
                                   FROM PermissionSetGroup
                                   WHERE DeveloperName =:psgMapping.PermissionSetGroup__c];


          //Assign permission set group to user  
          PermissionSetAssignment psa = new PermissionSetAssignment(
              PermissionSetId = psg.Id,
              AssigneeId = u.Id
          );

          insert psa;
    }


    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
                          String federationIdentifier, Map < String, String > attributes, String assertion){
    
        User u = [SELECT Id, ContactId, IsActive FROM User WHERE Id=:userId];

        
    
    }
}