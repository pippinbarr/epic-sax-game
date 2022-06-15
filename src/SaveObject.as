package
{
	public class SaveObject
	{
		public var completedPractice:Boolean = false;
		public var bestPracticeResult:uint = 0;
		public var completedStudio:Boolean = false;
		public var bestStudioResult:uint = 0;
		public var completedJam:Boolean = false;
		public var mostNotesPlayedInJam:uint = 0;
		public var completedEurovision:Boolean = false;
		public var bestEurovisionResult:uint = 1000;
		public var completedYouTube:Boolean = false;
		public var mostYouTubeLikes:uint = 0;
		
		public function SaveObject(object:SaveObject = null)
		{
			if (object != null)
			{
				trace("Constructing from a non-null object");
				completedPractice = object.completedPractice;
				bestPracticeResult = object.bestPracticeResult;
				completedStudio = object.completedStudio;
				bestStudioResult = object.bestStudioResult;
				completedJam = object.completedJam;
				mostNotesPlayedInJam = object.mostNotesPlayedInJam;
				completedEurovision = object.completedEurovision;
				bestEurovisionResult = object.bestEurovisionResult;
				completedYouTube = object.completedYouTube;
				mostYouTubeLikes = object.mostYouTubeLikes;
			}
			else
			{
				trace("Constructing from a null object");
			}
		}
	}
}