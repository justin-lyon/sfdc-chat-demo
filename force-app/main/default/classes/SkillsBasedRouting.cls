global class SkillsBasedRouting {
	@InvocableMethod
	public static void routeUsingSkills(List<String> cases) {
		List<Case> caseObjects = [SELECT Id, Description FROM Case WHERE Id in :cases];

		for (Case caseObj : caseObjects) {
			// Add SkillsBased PendingServiceRouting
			PendingServiceRouting psrObj = new PendingServiceRouting(
				CapacityWeight = 1,
				IsReadyForRouting = FALSE,
				RoutingModel  = 'MostAvailable',
				RoutingPriority = 1,
				RoutingType = 'SkillsBased',
				ServiceChannelId = getChannelId('Service_Channel_Name'),
				WorkItemId = caseObj.Id);
			insert psrObj;
			psrObj = [select id, IsReadyForRouting from PendingServiceRouting where id = : psrObj.id];

			// Now add SkillRequirement(s)
			SkillRequirement srObj = new SkillRequirement(
				RelatedRecordId = psrObj.id,
				SkillId = getSkillId(caseObj.Description),
				SkillLevel = 5);
			insert srObj;

			// Update PendingServiceRouting as IsReadyForRouting
			psrObj.IsReadyForRouting = TRUE;
			update psrObj;
		}
		return;
	}

	public static String getChannelId(String channelName) {
		ServiceChannel channel = [Select Id From ServiceChannel Where DeveloperName = :channelName];
		return channel.Id;
	}

	public static String getSkillId(String caseDescription) {
		String skillName = 'English';
		if (caseDescription != null) {
			if (caseDescription.contains('Spanish')) {
				skillName = 'Spanish';
			} else if (caseDescription.contains('French')) {
				skillName = 'French';
			}
		}

		Skill skill = [Select Id From Skill Where DeveloperName = :skillName];
		return skill.Id;
	}
}