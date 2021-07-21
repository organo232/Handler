trigger CreateCaseContact on Case (before insert) {
    List<String> UseremailAddresses = new List<String>();
    //First exclude any cases where the contact is set
    for (Case c:Trigger.new) {
        if (c.ContactId==null &&
            c.SuppliedEmail!=''|| c.SuppliedEmail==null)
        {
            UseremailAddresses.add(c.SuppliedEmail);
        }
    }

    //Now we have a nice list of all the email addresses.  Let's query on it and see how many contacts already exist.
    List<Contact> listofallContacts = [Select Id,Email From Contact Where Email in:UseremailAddresses];
    Set<String> ExstingEmails = new Set<String>();
    for (Contact c:listofallContacts) {
        ExstingEmails.add(c.Email);
    }
    
    Map<String,Contact> emailToContactMap = new Map<String,Contact>();
    List<Case> casesToUpdate = new List<Case>();

    for (Case c:Trigger.new) {
        if (c.ContactId==null &&
            c.SuppliedName!=null &&
            c.SuppliedEmail!=null &&
            c.SuppliedName!='' &&
           !c.SuppliedName.contains('@') &&
            c.SuppliedEmail!='' &&
           !ExstingEmails.contains(c.SuppliedEmail))
        {
            //The case was created with a null contact
            //Let's make a contact for it
            String[] Emailheader = c.SuppliedName.split(' ',2);
            if (Emailheader.size() == 2)
            {
                Contact conts = new Contact(FirstName=Emailheader[0],
                                            LastName=Emailheader[1],
                                            Email=c.SuppliedEmail
                                            );
                emailToContactMap.put(c.SuppliedEmail,conts);
                casesToUpdate.add(c);
            }
        }
    }
    
    List<Contact> newContacts = emailToContactMap.values();
    insert newContacts;
    
    for (Case c:casesToUpdate) {
        Contact newContact = emailToContactMap.get(c.SuppliedEmail);
        
        c.ContactId = newContact.Id;
    }
}