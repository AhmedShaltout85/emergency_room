class CaseReport {
  final int id;
  final String caseReportDateTime;
  final String waterStopingDateTime;
  final String? caseRepairDateTime;
  final String? waterOpeningDateTime;
  final String notes;
  final bool finalClosed;
  final String reporterName;
  // Add all other fields...

  CaseReport({
    required this.id,
    required this.caseReportDateTime,
    required this.waterStopingDateTime,
    this.caseRepairDateTime,
    this.waterOpeningDateTime,
    required this.notes,
    required this.finalClosed,
    required this.reporterName,
    // Initialize all other fields...
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caseReportDateTime': caseReportDateTime,
      'waterStopingDateTime': waterStopingDateTime,
      'caseRepairDateTime': caseRepairDateTime,
      'waterOpeningDateTime': waterOpeningDateTime,
      'notes': notes,
      'finalClosed': finalClosed,
      'reporterName': reporterName,
      // Include all other fields...
    };
  }
}


// void postData() async {
 

//   final reports = [
//     {
//       "id": 395923,
//       "caseReportDateTime": "2025-04-08T14:03:02.76",
//       "waterStopingDateTime": "2025-04-08T13:59:29.317",
//       "caseRepairDateTime": null,
//       "waterOpeningDateTime": null,
//       "notes": "12 بوصة 2 بلف ا/ احمد عيسى",
//       "finalClosed": false,
//       "reporterName": "ا/ احمد عيسى",
//       "refNo": null,
//       "street": "طريق الكورنيش امام فندق ريجينسى - العصافرة بحرى",
//       "mainStreet": "",
//       "x": "",
//       "y": "",
//       "nearTo": "",
//       "userName": "احمد  خميس عثمان",
//       "area": "العصافرة بحرى",
//       "town": "حى المنتزة",
//       "sector": "قطاع شرق",
//       "locationName": "المندرة (حى المنتزة)",
//       "companyAcroName": " مياه الاسكندرية",
//       "caseType": "كسر ماسورة",
//       "activityName": "مياه",
//       "valvesCount": 2,
//       "network": "",
//       "pressure": 0.00,
//       "details": "",
//       "extraDataNotes": "",
//       "pipeDiameter": 300,
//       "pipeType": "",
//       "pipeStatus": "",
//       "pipeDepth": "",
//       "pipeAge": "",
//       "breakLength": 0.00,
//       "bearkWidth": 0.00,
//       "plantName": "",
//       "plantStatus": "",
//       "affectedAreas": "العصافرة بحرى",
//       "resons": "",
//       "repairType": "",
//       "delayResons": ""
//     }
//   ];

//   try {
//     // await DioNetworkRepos().postHotLineDataList(reports);
//     log('Data posted successfully');
//   } catch (e) {
//     log('Error posting data: $e');
//   }
// }
