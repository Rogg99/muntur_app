class Filter{
  String keyword;
  String pays_id;
  String region_id;
  String dept_id;
  String deptorg_id;
  String commune_id;
  String militant_type;
  searchType type;
  bool commune;
  bool department;
  bool department_org;
  bool region;
  bool pays;
  bool bv;
  bool cb;
  bool sca;
  bool dob;
  bool last_24h;
  bool last_month;
  bool dor;
  bool n18_19;
  int date_start;
  int date_end;
  int birth_start;
  int birth_end;
  Filter({
    this.keyword = '',
    this.type = searchType.militant,
    this.commune = false,
    this.department = false,
    this.department_org = false,
    this.region = false,
    this.pays = false,
    this.bv = false,
    this.cb = false,
    this.sca = false,
    this.dob = false,
    this.dor = false,
    this.n18_19 = false,
    this.last_24h = false,
    this.last_month = false,
    this.date_end = 0,
    this.date_start = 0,
    this.birth_end = 0,
    this.birth_start = 0,
    this.pays_id='',
    this.militant_type='Militant',
    this.region_id='',
    this.dept_id='',
    this.deptorg_id='',
    this.commune_id='',
  });

  Map<String, dynamic> toMap() {
    return {
      'key': keyword,
      'pays_id': pays_id,
      'region_id':region_id ,
      'dept_id': dept_id,
      'poste': militant_type,
      'deptorg_id': deptorg_id,
      'commune_id': commune_id,
      'object_': getTypeName(type),
      'commune': commune,
      'departement': department,
      'departement_org': department_org,
      'region': region,
      'pays': pays,
      'bv': bv,
      'cb': cb,
      'sca': sca,
      'age': dob,
      'creation_date': dor,
      'n18_19': n18_19,
      'last_24h': last_24h,
      'last_month': last_month,
      'creation_end': date_end,
      'creation_start': date_start,
      'age_end': birth_end,
      'age_start': birth_start,
    };
  }
  String getTypeName(searchType type){
    if(type==searchType.bv)
      return 'Bv';
    else if(type==searchType.preInscription)
      return 'Preinscription';
    else if(type==searchType.inscription)
      return 'Inscription';
    else if(type==searchType.commune)
      return 'Commune';
    else if(type==searchType.region)
      return 'Region';
    else if(type==searchType.pays)
      return 'Pays';
    else if(type==searchType.department)
      return 'Departement';
    else if(type==searchType.user)
      return 'User';
    else
      return 'Militant';
  }
}
enum searchType{
  militant,
  user,
  inscription,
  preInscription,
  bv,
  commune,
  department,
  region,
  pays,
}