public class HC_cls_JSON2Apex {
	public List<Data> data {get;set;} 

	
	public class Region {
		public String iso {get;set;} 
		public String name {get;set;} 
		public String province {get;set;} 
		public String lat {get;set;} 
		public String long_Z {get;set;} // in json: long
		public List<Cities> cities {get;set;} 
	}
	
	public class Data {
		public Date date_Z {get;set;} // in json: date
		public Integer confirmed {get;set;} 
		public Integer deaths {get;set;} 
		public Integer recovered {get;set;} 
		public Integer confirmed_diff {get;set;} 
		public Integer deaths_diff {get;set;} 
		public Integer recovered_diff {get;set;} 
		public String last_update {get;set;} 
		public Integer active {get;set;} 
		public Integer active_diff {get;set;} 
		public Double fatality_rate {get;set;} 
		public Region region {get;set;} 
	}
	
	public class Cities {
		public String name {get;set;} 
		public String date_Z {get;set;} // in json: date
		public Integer fips {get;set;} 
		public String lat {get;set;} 
		public String long_Z {get;set;} // in json: long
		public Integer confirmed {get;set;} 
		public Integer deaths {get;set;} 
		public Integer confirmed_diff {get;set;} 
		public Integer deaths_diff {get;set;} 
		public String last_update {get;set;} 

	}
	
}