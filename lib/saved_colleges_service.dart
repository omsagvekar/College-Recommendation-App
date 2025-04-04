class SavedCollegesService {
  static final SavedCollegesService _instance = SavedCollegesService._internal();
  final List<Map<String, dynamic>> _savedColleges = [];

  factory SavedCollegesService() {
    return _instance;
  }

  SavedCollegesService._internal();

  List<Map<String, dynamic>> get savedColleges => _savedColleges;

  void saveCollege(Map<String, dynamic> college) {
    if (!_savedColleges.any((c) =>
    c['college_name'] == college['college_name'] &&
        c['branch'] == college['branch'] &&
        c['seat_type'] == college['seat_type'])) {
      _savedColleges.add(college);
    }
  }

  void removeCollege(Map<String, dynamic> college) {
    _savedColleges.removeWhere((c) =>
    c['college_name'] == college['college_name'] &&
        c['branch'] == college['branch'] &&
        c['seat_type'] == college['seat_type']);
  }

  bool isCollegeSaved(Map<String, dynamic> college) {
    return _savedColleges.any((c) =>
    c['college_name'] == college['college_name'] &&
        c['branch'] == college['branch'] &&
        c['seat_type'] == college['seat_type']);
  }
}
