String convertLabCodeToLabName(int labCode) {
  if (labCode == 7) {
    return "معمل محطة السيوف";
  } else if (labCode == 8) {
    return "معمل محطة المعمورة";
  } else if (labCode == 9) {
    return "معمل محطة شرقي";
  } else if (labCode == 10) {
    return "معمل محطة المنشية 2";
  } else if (labCode == 11) {
    return "معمل محطة المنشية 1";
  } else if (labCode == 13) {
    return "معمل محطة مريوط 1";
  } else {
    return "معمل محطة السيوف";
  }
}
