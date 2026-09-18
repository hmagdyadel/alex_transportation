import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ALEXBANK TRANSIT'**
  String get appName;

  /// No description provided for @alexBank.
  ///
  /// In en, this message translates to:
  /// **'ALEXBANK'**
  String get alexBank;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to end your current session?'**
  String get signOutConfirmMessage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get italian;

  /// No description provided for @splashSlogan.
  ///
  /// In en, this message translates to:
  /// **'Employee Transport & Mobility Portal'**
  String get splashSlogan;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Executive Garage Parking'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Desc.
  ///
  /// In en, this message translates to:
  /// **'Automated monthly smart parking subscriptions, live bay availability tracking, and seamless QR gate access.'**
  String get onboardingSlide1Desc;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Corporate Shuttle Network'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Desc.
  ///
  /// In en, this message translates to:
  /// **'Book seats on daily regional lines to Smart Village (AlexBank HQ) with real-time waypoint progression.'**
  String get onboardingSlide2Desc;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Official Errand Dispatch'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Desc.
  ///
  /// In en, this message translates to:
  /// **'On-demand company vehicles for business missions, branch visits, and executive transport with digital dispatch passes.'**
  String get onboardingSlide3Desc;

  /// No description provided for @accessGateTitle.
  ///
  /// In en, this message translates to:
  /// **'ALEXBANK TRANSIT'**
  String get accessGateTitle;

  /// No description provided for @accessGateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Staff Transportation & Corporate Fleet Management'**
  String get accessGateSubtitle;

  /// No description provided for @signInCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Transit Portal'**
  String get signInCardTitle;

  /// No description provided for @signInCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your role and enter your Bank ISL & Password.'**
  String get signInCardSubtitle;

  /// No description provided for @selectRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'SELECT PORTAL ROLE'**
  String get selectRoleLabel;

  /// No description provided for @roleNormalUser.
  ///
  /// In en, this message translates to:
  /// **'Normal User'**
  String get roleNormalUser;

  /// No description provided for @roleDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get roleDriver;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @staffIslLabel.
  ///
  /// In en, this message translates to:
  /// **'BANK STAFF ISL'**
  String get staffIslLabel;

  /// No description provided for @staffIslHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 10492 or ADM-9001'**
  String get staffIslHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @quickFillLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick Fill:'**
  String get quickFillLabel;

  /// No description provided for @quickFillNormalUser.
  ///
  /// In en, this message translates to:
  /// **'Normal User (10492)'**
  String get quickFillNormalUser;

  /// No description provided for @quickFillDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver (DRV-2001)'**
  String get quickFillDriver;

  /// No description provided for @quickFillAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin (ADM-9001)'**
  String get quickFillAdmin;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Transit'**
  String get signInButton;

  /// No description provided for @helpdeskFooter.
  ///
  /// In en, this message translates to:
  /// **'Fleet Admin Helpdesk: ext. 4200'**
  String get helpdeskFooter;

  /// No description provided for @enterIslError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Bank Staff ISL'**
  String get enterIslError;

  /// No description provided for @enterPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPasswordError;

  /// No description provided for @passwordMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 4 characters'**
  String get passwordMinLengthError;

  /// No description provided for @employeePortalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transit — Employee Portal'**
  String get employeePortalSubtitle;

  /// No description provided for @adminEmployeeModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transit — Admin (Employee Mode)'**
  String get adminEmployeeModeSubtitle;

  /// No description provided for @roleEmployee.
  ///
  /// In en, this message translates to:
  /// **'EMPLOYEE'**
  String get roleEmployee;

  /// No description provided for @roleCaptain.
  ///
  /// In en, this message translates to:
  /// **'CAPTAIN'**
  String get roleCaptain;

  /// No description provided for @roleAdminBadge.
  ///
  /// In en, this message translates to:
  /// **'ADMIN'**
  String get roleAdminBadge;

  /// No description provided for @roleAdminUserMode.
  ///
  /// In en, this message translates to:
  /// **'ADMIN (USER MODE)'**
  String get roleAdminUserMode;

  /// No description provided for @returnToAdminTooltip.
  ///
  /// In en, this message translates to:
  /// **'Return to Admin Console'**
  String get returnToAdminTooltip;

  /// No description provided for @moduleGarage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get moduleGarage;

  /// No description provided for @moduleBuses.
  ///
  /// In en, this message translates to:
  /// **'Buses'**
  String get moduleBuses;

  /// No description provided for @moduleErrandCars.
  ///
  /// In en, this message translates to:
  /// **'Errand Cars'**
  String get moduleErrandCars;

  /// No description provided for @garageHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'AlexBank Corporate Garage'**
  String get garageHeaderTitle;

  /// No description provided for @garageHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Executive multi-level parking facility'**
  String get garageHeaderSubtitle;

  /// No description provided for @garageTabMyPass.
  ///
  /// In en, this message translates to:
  /// **'My Pass'**
  String get garageTabMyPass;

  /// No description provided for @garageTabSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get garageTabSubscribe;

  /// No description provided for @garageTabLookup.
  ///
  /// In en, this message translates to:
  /// **'Status Lookup'**
  String get garageTabLookup;

  /// No description provided for @garageTabCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get garageTabCancel;

  /// No description provided for @garageTotalSlots.
  ///
  /// In en, this message translates to:
  /// **'Total Slots'**
  String get garageTotalSlots;

  /// No description provided for @garageAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get garageAvailable;

  /// No description provided for @garageVipReserved.
  ///
  /// In en, this message translates to:
  /// **'VIP Reserved'**
  String get garageVipReserved;

  /// No description provided for @garageLiveOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Live Occupancy'**
  String get garageLiveOccupancy;

  /// No description provided for @garagePassCardTitle.
  ///
  /// In en, this message translates to:
  /// **'AlexBank Garage Pass'**
  String get garagePassCardTitle;

  /// No description provided for @garageAssignedBay.
  ///
  /// In en, this message translates to:
  /// **'Assigned Bay'**
  String get garageAssignedBay;

  /// No description provided for @garageEntryDate.
  ///
  /// In en, this message translates to:
  /// **'Entry Date'**
  String get garageEntryDate;

  /// No description provided for @garageCheckInAction.
  ///
  /// In en, this message translates to:
  /// **'Check In to Bay'**
  String get garageCheckInAction;

  /// No description provided for @garageCheckOutAction.
  ///
  /// In en, this message translates to:
  /// **'Check Out from Bay'**
  String get garageCheckOutAction;

  /// No description provided for @garageCheckedInStatus.
  ///
  /// In en, this message translates to:
  /// **'Currently Parked'**
  String get garageCheckedInStatus;

  /// No description provided for @garageCheckedOutStatus.
  ///
  /// In en, this message translates to:
  /// **'Outside Garage'**
  String get garageCheckedOutStatus;

  /// No description provided for @garageMonthlyDeductionNotice.
  ///
  /// In en, this message translates to:
  /// **'Monthly Subscription Fee: 1,200 EGP deducted automatically via payroll.'**
  String get garageMonthlyDeductionNotice;

  /// No description provided for @garageSubscriptionFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Parking Pass Application'**
  String get garageSubscriptionFormTitle;

  /// No description provided for @garageEmployeeName.
  ///
  /// In en, this message translates to:
  /// **'Employee Full Name'**
  String get garageEmployeeName;

  /// No description provided for @garageNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID (14 digits)'**
  String get garageNationalId;

  /// No description provided for @garageEmail.
  ///
  /// In en, this message translates to:
  /// **'Corporate Email (@alexbank.com)'**
  String get garageEmail;

  /// No description provided for @garagePlate.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Plate Number'**
  String get garagePlate;

  /// No description provided for @garageConsentCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I authorize monthly payroll deduction of the parking tariff.'**
  String get garageConsentCheckbox;

  /// No description provided for @garageSubmitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Subscription Request'**
  String get garageSubmitApplication;

  /// No description provided for @garageLookupTitle.
  ///
  /// In en, this message translates to:
  /// **'Check Application Status'**
  String get garageLookupTitle;

  /// No description provided for @garageEnterIslSearch.
  ///
  /// In en, this message translates to:
  /// **'Enter Bank ISL to track status'**
  String get garageEnterIslSearch;

  /// No description provided for @garageCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Parking Subscription'**
  String get garageCancelTitle;

  /// No description provided for @garageCancelReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for cancellation'**
  String get garageCancelReason;

  /// No description provided for @garageSubmitCancellation.
  ///
  /// In en, this message translates to:
  /// **'Request Cancellation'**
  String get garageSubmitCancellation;

  /// No description provided for @busActivePassHeader.
  ///
  /// In en, this message translates to:
  /// **'Your Active Boarding Pass'**
  String get busActivePassHeader;

  /// No description provided for @busShuttlePassTitle.
  ///
  /// In en, this message translates to:
  /// **'AlexBank Shuttle Pass'**
  String get busShuttlePassTitle;

  /// No description provided for @busSeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Seat'**
  String get busSeatLabel;

  /// No description provided for @busPickupStopLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup Station'**
  String get busPickupStopLabel;

  /// No description provided for @busDepartureTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get busDepartureTimeLabel;

  /// No description provided for @busRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get busRouteLabel;

  /// No description provided for @busBoardAction.
  ///
  /// In en, this message translates to:
  /// **'Board Bus'**
  String get busBoardAction;

  /// No description provided for @busBoardedAction.
  ///
  /// In en, this message translates to:
  /// **'Boarded'**
  String get busBoardedAction;

  /// No description provided for @busCancelReservation.
  ///
  /// In en, this message translates to:
  /// **'Cancel Reservation'**
  String get busCancelReservation;

  /// No description provided for @busFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All Shifts'**
  String get busFilterAll;

  /// No description provided for @busFilterMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning Shifts'**
  String get busFilterMorning;

  /// No description provided for @busFilterEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening Return'**
  String get busFilterEvening;

  /// No description provided for @busAvailableSeats.
  ///
  /// In en, this message translates to:
  /// **'Available Seats'**
  String get busAvailableSeats;

  /// No description provided for @busStopsCount.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get busStopsCount;

  /// No description provided for @busReserveSeatAction.
  ///
  /// In en, this message translates to:
  /// **'Reserve Seat'**
  String get busReserveSeatAction;

  /// No description provided for @busRouteFull.
  ///
  /// In en, this message translates to:
  /// **'Fully Booked'**
  String get busRouteFull;

  /// No description provided for @busTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Route Stations Timeline'**
  String get busTimelineTitle;

  /// No description provided for @busDriverCaptain.
  ///
  /// In en, this message translates to:
  /// **'Captain'**
  String get busDriverCaptain;

  /// No description provided for @busSmartVillageDestination.
  ///
  /// In en, this message translates to:
  /// **'Smart Village (AlexBank HQ)'**
  String get busSmartVillageDestination;

  /// No description provided for @errandFleetOverview.
  ///
  /// In en, this message translates to:
  /// **'Official Fleet Vehicles'**
  String get errandFleetOverview;

  /// No description provided for @errandAvailableVehicles.
  ///
  /// In en, this message translates to:
  /// **'Available Cars'**
  String get errandAvailableVehicles;

  /// No description provided for @errandOfficialUseBadge.
  ///
  /// In en, this message translates to:
  /// **'OFFICIAL USE'**
  String get errandOfficialUseBadge;

  /// No description provided for @errandTabMyMissions.
  ///
  /// In en, this message translates to:
  /// **'My Missions'**
  String get errandTabMyMissions;

  /// No description provided for @errandTabRequestVehicle.
  ///
  /// In en, this message translates to:
  /// **'Request Vehicle'**
  String get errandTabRequestVehicle;

  /// No description provided for @errandTabTrackStatus.
  ///
  /// In en, this message translates to:
  /// **'Track Status'**
  String get errandTabTrackStatus;

  /// No description provided for @errandPassTitle.
  ///
  /// In en, this message translates to:
  /// **'Official Errand Dispatch Pass'**
  String get errandPassTitle;

  /// No description provided for @errandMissionCode.
  ///
  /// In en, this message translates to:
  /// **'Mission Code'**
  String get errandMissionCode;

  /// No description provided for @errandAssignedVehicle.
  ///
  /// In en, this message translates to:
  /// **'Assigned Vehicle'**
  String get errandAssignedVehicle;

  /// No description provided for @errandPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get errandPlateNumber;

  /// No description provided for @errandPickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Pickup Point'**
  String get errandPickupPoint;

  /// No description provided for @errandDestination.
  ///
  /// In en, this message translates to:
  /// **'DESTINATION'**
  String get errandDestination;

  /// No description provided for @errandDepartureTime.
  ///
  /// In en, this message translates to:
  /// **'DEPARTURE TIME'**
  String get errandDepartureTime;

  /// No description provided for @errandReturnTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Return'**
  String get errandReturnTime;

  /// No description provided for @errandStartOdometer.
  ///
  /// In en, this message translates to:
  /// **'Start Odometer'**
  String get errandStartOdometer;

  /// No description provided for @errandEndOdometer.
  ///
  /// In en, this message translates to:
  /// **'End Odometer'**
  String get errandEndOdometer;

  /// No description provided for @errandTotalDistance.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get errandTotalDistance;

  /// No description provided for @errandStartMissionAction.
  ///
  /// In en, this message translates to:
  /// **'Start Mission'**
  String get errandStartMissionAction;

  /// No description provided for @errandEndMissionAction.
  ///
  /// In en, this message translates to:
  /// **'End Mission'**
  String get errandEndMissionAction;

  /// No description provided for @errandEnterReturnOdometer.
  ///
  /// In en, this message translates to:
  /// **'Enter Return Odometer (km)'**
  String get errandEnterReturnOdometer;

  /// No description provided for @errandRequestFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Official Errand Vehicle'**
  String get errandRequestFormTitle;

  /// No description provided for @errandDepartmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Department / Unit'**
  String get errandDepartmentLabel;

  /// No description provided for @errandPickupLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get errandPickupLocationLabel;

  /// No description provided for @errandDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination Branch / Office'**
  String get errandDestinationLabel;

  /// No description provided for @errandMissionPurposeLabel.
  ///
  /// In en, this message translates to:
  /// **'Purpose of Mission'**
  String get errandMissionPurposeLabel;

  /// No description provided for @errandSupervisorLabel.
  ///
  /// In en, this message translates to:
  /// **'Direct Supervisor Name'**
  String get errandSupervisorLabel;

  /// No description provided for @errandSubmitRequestAction.
  ///
  /// In en, this message translates to:
  /// **'Submit Vehicle Request'**
  String get errandSubmitRequestAction;

  /// No description provided for @errandCancelRequestAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get errandCancelRequestAction;

  /// No description provided for @errandPendingMissions.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get errandPendingMissions;

  /// No description provided for @errandActiveMissions.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get errandActiveMissions;

  /// No description provided for @errandCompletedMissions.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get errandCompletedMissions;

  /// No description provided for @driverPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Transit — Driver Portal'**
  String get driverPortalTitle;

  /// No description provided for @driverCaptainPill.
  ///
  /// In en, this message translates to:
  /// **'CAPTAIN'**
  String get driverCaptainPill;

  /// No description provided for @driverEndShift.
  ///
  /// In en, this message translates to:
  /// **'End Shift & Sign Out'**
  String get driverEndShift;

  /// No description provided for @driverEndShiftConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to end your driver shift and return to the access gate?'**
  String get driverEndShiftConfirm;

  /// No description provided for @driverTabHud.
  ///
  /// In en, this message translates to:
  /// **'Live Trip HUD'**
  String get driverTabHud;

  /// No description provided for @driverTabManifest.
  ///
  /// In en, this message translates to:
  /// **'Passenger Manifest'**
  String get driverTabManifest;

  /// No description provided for @driverTabInspection.
  ///
  /// In en, this message translates to:
  /// **'Safety Inspection'**
  String get driverTabInspection;

  /// No description provided for @driverRating.
  ///
  /// In en, this message translates to:
  /// **'Safety Rating'**
  String get driverRating;

  /// No description provided for @driverBusPlate.
  ///
  /// In en, this message translates to:
  /// **'Bus Plate'**
  String get driverBusPlate;

  /// No description provided for @driverCurrentStop.
  ///
  /// In en, this message translates to:
  /// **'Current Station'**
  String get driverCurrentStop;

  /// No description provided for @driverNextStop.
  ///
  /// In en, this message translates to:
  /// **'Next Station'**
  String get driverNextStop;

  /// No description provided for @driverStartRoute.
  ///
  /// In en, this message translates to:
  /// **'Start Route Trip'**
  String get driverStartRoute;

  /// No description provided for @driverDepartStop.
  ///
  /// In en, this message translates to:
  /// **'Depart to Next Station'**
  String get driverDepartStop;

  /// No description provided for @driverFinalArrival.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Final Station'**
  String get driverFinalArrival;

  /// No description provided for @driverCompleteTrip.
  ///
  /// In en, this message translates to:
  /// **'Complete Trip'**
  String get driverCompleteTrip;

  /// No description provided for @driverManifestTitle.
  ///
  /// In en, this message translates to:
  /// **'Passenger Roster'**
  String get driverManifestTitle;

  /// No description provided for @driverBoardedCount.
  ///
  /// In en, this message translates to:
  /// **'Boarded'**
  String get driverBoardedCount;

  /// No description provided for @driverFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get driverFilterAll;

  /// No description provided for @driverFilterAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting'**
  String get driverFilterAwaiting;

  /// No description provided for @driverFilterBoarded.
  ///
  /// In en, this message translates to:
  /// **'Boarded'**
  String get driverFilterBoarded;

  /// No description provided for @driverBoardButton.
  ///
  /// In en, this message translates to:
  /// **'BOARD'**
  String get driverBoardButton;

  /// No description provided for @driverBoardedBadge.
  ///
  /// In en, this message translates to:
  /// **'BOARDED'**
  String get driverBoardedBadge;

  /// No description provided for @driverInspectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-Trip Vehicle Safety Inspection'**
  String get driverInspectionTitle;

  /// No description provided for @driverInspectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mandatory safety checklist prior to passenger boarding'**
  String get driverInspectionSubtitle;

  /// No description provided for @driverInspectionReady.
  ///
  /// In en, this message translates to:
  /// **'VEHICLE INSPECTED & CERTIFIED SAFE'**
  String get driverInspectionReady;

  /// No description provided for @driverCheckBrakes.
  ///
  /// In en, this message translates to:
  /// **'Braking system and hydraulic fluid levels'**
  String get driverCheckBrakes;

  /// No description provided for @driverCheckTires.
  ///
  /// In en, this message translates to:
  /// **'Tire pressure and tread integrity'**
  String get driverCheckTires;

  /// No description provided for @driverCheckEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency exits and safety hammer presence'**
  String get driverCheckEmergency;

  /// No description provided for @driverCheckFirstAid.
  ///
  /// In en, this message translates to:
  /// **'First aid emergency medical kit stocked'**
  String get driverCheckFirstAid;

  /// No description provided for @driverCheckMirrors.
  ///
  /// In en, this message translates to:
  /// **'Side and rear passenger visibility mirrors'**
  String get driverCheckMirrors;

  /// No description provided for @driverCheckFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel / battery level above 50% minimum'**
  String get driverCheckFuel;

  /// No description provided for @adminConsoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Transit — Central Mobility Console'**
  String get adminConsoleTitle;

  /// No description provided for @adminTabBuses.
  ///
  /// In en, this message translates to:
  /// **'Bus Transit'**
  String get adminTabBuses;

  /// No description provided for @adminTabGarage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get adminTabGarage;

  /// No description provided for @adminTabErrand.
  ///
  /// In en, this message translates to:
  /// **'Errand Fleet'**
  String get adminTabErrand;

  /// No description provided for @adminTabDrivers.
  ///
  /// In en, this message translates to:
  /// **'Captains'**
  String get adminTabDrivers;

  /// No description provided for @adminTabSecurity.
  ///
  /// In en, this message translates to:
  /// **'Access & Security'**
  String get adminTabSecurity;

  /// No description provided for @adminDualAccessBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'ADMIN DUAL ACCESS & MOBILITY'**
  String get adminDualAccessBannerTitle;

  /// No description provided for @adminDualAccessBannerDesc.
  ///
  /// In en, this message translates to:
  /// **'As an Administrator, you can switch to Employee Mode to park in the garage, book bus lines, or request errand cars — and return to this console anytime.'**
  String get adminDualAccessBannerDesc;

  /// No description provided for @adminOpenStaffServices.
  ///
  /// In en, this message translates to:
  /// **'Open Staff Services (Garage/Buses)'**
  String get adminOpenStaffServices;

  /// No description provided for @adminInspectDriverHud.
  ///
  /// In en, this message translates to:
  /// **'Inspect Driver HUD'**
  String get adminInspectDriverHud;

  /// No description provided for @adminAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'ADMINISTRATOR ACCOUNTS'**
  String get adminAccountsTitle;

  /// No description provided for @adminAccountsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Staff members with full fleet administration access'**
  String get adminAccountsSubtitle;

  /// No description provided for @adminAddAdminButton.
  ///
  /// In en, this message translates to:
  /// **'+ Add Admin'**
  String get adminAddAdminButton;

  /// No description provided for @adminProvisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Provision New Admin'**
  String get adminProvisionTitle;

  /// No description provided for @adminProvisionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an authorized administrator account with full console management access.'**
  String get adminProvisionSubtitle;

  /// No description provided for @adminFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'ADMIN FULL NAME'**
  String get adminFullNameLabel;

  /// No description provided for @adminDeptLabel.
  ///
  /// In en, this message translates to:
  /// **'DEPARTMENT / DIVISION'**
  String get adminDeptLabel;

  /// No description provided for @adminInitialPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'INITIAL PASSWORD'**
  String get adminInitialPasswordLabel;

  /// No description provided for @adminProvisionSubmit.
  ///
  /// In en, this message translates to:
  /// **'Provision Admin'**
  String get adminProvisionSubmit;

  /// No description provided for @adminActiveAdminBadge.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE ADMIN'**
  String get adminActiveAdminBadge;

  /// No description provided for @adminBusRoutesManager.
  ///
  /// In en, this message translates to:
  /// **'BUS ROUTES & STATIONS MANAGER'**
  String get adminBusRoutesManager;

  /// No description provided for @adminMirroredLineNotice.
  ///
  /// In en, this message translates to:
  /// **'Sync Mirrored Return Evening Line (Smart Village HQ -> Cairo Stations)'**
  String get adminMirroredLineNotice;

  /// No description provided for @adminSyncMirroredAction.
  ///
  /// In en, this message translates to:
  /// **'Sync Mirrored Return Line'**
  String get adminSyncMirroredAction;

  /// No description provided for @adminAddStationAction.
  ///
  /// In en, this message translates to:
  /// **'+ Add Station'**
  String get adminAddStationAction;

  /// No description provided for @adminGarageTariffTitle.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY PARKING TARIFF'**
  String get adminGarageTariffTitle;

  /// No description provided for @adminGarageTariffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configurable standard monthly employee parking deduction'**
  String get adminGarageTariffSubtitle;

  /// No description provided for @adminGarageAdjustFee.
  ///
  /// In en, this message translates to:
  /// **'Adjust Tariff'**
  String get adminGarageAdjustFee;

  /// No description provided for @adminErrandMissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'CORPORATE ERRAND MISSIONS'**
  String get adminErrandMissionsTitle;

  /// No description provided for @adminErrandDualPoint.
  ///
  /// In en, this message translates to:
  /// **'Dual-Point Route: Pickup -> Destination'**
  String get adminErrandDualPoint;

  /// No description provided for @adminCaptainsRosterTitle.
  ///
  /// In en, this message translates to:
  /// **'TRANSIT FLEET CAPTAINS & CHAUFFEURS'**
  String get adminCaptainsRosterTitle;

  /// No description provided for @adminInviteCodesTitle.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE INVITE CODES'**
  String get adminInviteCodesTitle;

  /// No description provided for @adminGenerateCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'GENERATE ACCESS INVITE CODE'**
  String get adminGenerateCodeTitle;

  /// No description provided for @adminGenerateCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Secure Code'**
  String get adminGenerateCodeButton;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get commonToday;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get commonSignOut;

  /// No description provided for @commonStops.
  ///
  /// In en, this message translates to:
  /// **'STOPS'**
  String get commonStops;

  /// No description provided for @errandFleetAvailability.
  ///
  /// In en, this message translates to:
  /// **'FLEET AVAILABILITY'**
  String get errandFleetAvailability;

  /// No description provided for @errandCarsAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Cars Available'**
  String errandCarsAvailableCount(Object count);

  /// No description provided for @errandDispatchedCount.
  ///
  /// In en, this message translates to:
  /// **'{dispatched} of {total} vehicles dispatched'**
  String errandDispatchedCount(Object dispatched, Object total);

  /// No description provided for @errandUtilizedPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Utilized'**
  String errandUtilizedPercent(Object percent);

  /// No description provided for @errandActiveDispatchPass.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE DISPATCH PASS'**
  String get errandActiveDispatchPass;

  /// No description provided for @errandEndMissionRecordMileage.
  ///
  /// In en, this message translates to:
  /// **'END MISSION — RECORD RETURN MILEAGE'**
  String get errandEndMissionRecordMileage;

  /// No description provided for @errandOdometerReadingKm.
  ///
  /// In en, this message translates to:
  /// **'ODOMETER READING (KM)'**
  String get errandOdometerReadingKm;

  /// No description provided for @errandCompleteMissionAndReturn.
  ///
  /// In en, this message translates to:
  /// **'Complete Mission & Return Vehicle'**
  String get errandCompleteMissionAndReturn;

  /// No description provided for @errandEnterValidMileage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid mileage reading'**
  String get errandEnterValidMileage;

  /// No description provided for @errandNoActiveMissions.
  ///
  /// In en, this message translates to:
  /// **'No Active Missions'**
  String get errandNoActiveMissions;

  /// No description provided for @errandNoActiveMissionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Submit a vehicle request to get a dispatch pass for your corporate errand.'**
  String get errandNoActiveMissionsDesc;

  /// No description provided for @errandRequestAVehicleAction.
  ///
  /// In en, this message translates to:
  /// **'Request a Vehicle'**
  String get errandRequestAVehicleAction;

  /// No description provided for @errandRequestHistory.
  ///
  /// In en, this message translates to:
  /// **'REQUEST HISTORY'**
  String get errandRequestHistory;

  /// No description provided for @errandNewVehicleRequest.
  ///
  /// In en, this message translates to:
  /// **'New Vehicle Request'**
  String get errandNewVehicleRequest;

  /// No description provided for @errandRequestDesc.
  ///
  /// In en, this message translates to:
  /// **'Request an official bank vehicle for corporate errands.'**
  String get errandRequestDesc;

  /// No description provided for @errandFullName.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get errandFullName;

  /// No description provided for @errandBankIsl.
  ///
  /// In en, this message translates to:
  /// **'BANK ISL (4-8 DIGITS)'**
  String get errandBankIsl;

  /// No description provided for @errandDepartment.
  ///
  /// In en, this message translates to:
  /// **'DEPARTMENT'**
  String get errandDepartment;

  /// No description provided for @errandPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'PICKUP LOCATION'**
  String get errandPickupLocation;

  /// No description provided for @errandMissionPurpose.
  ///
  /// In en, this message translates to:
  /// **'MISSION PURPOSE'**
  String get errandMissionPurpose;

  /// No description provided for @errandMissionPurposeHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the reason for this errand'**
  String get errandMissionPurposeHint;

  /// No description provided for @errandEstimatedReturn.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED RETURN'**
  String get errandEstimatedReturn;

  /// No description provided for @errandSupervisorName.
  ///
  /// In en, this message translates to:
  /// **'SUPERVISOR NAME'**
  String get errandSupervisorName;

  /// No description provided for @errandReviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Your request will be reviewed by the fleet administrator. A vehicle will be assigned based on availability and supervisor approval.'**
  String get errandReviewNotice;

  /// No description provided for @errandNoRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No Requests Found'**
  String get errandNoRequestsFound;

  /// No description provided for @errandNoRequestsFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'You have not submitted any errand car requests yet.'**
  String get errandNoRequestsFoundDesc;

  /// No description provided for @errandCancelRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Errand Request'**
  String get errandCancelRequestTitle;

  /// No description provided for @errandCancelRequestConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this vehicle request? If a car has been assigned, it will be released back to the fleet.'**
  String get errandCancelRequestConfirm;

  /// No description provided for @errandKeepRequest.
  ///
  /// In en, this message translates to:
  /// **'Keep Request'**
  String get errandKeepRequest;

  /// No description provided for @errandRequestApprovedPassIssued.
  ///
  /// In en, this message translates to:
  /// **'Request approved! Dispatch pass issued.'**
  String get errandRequestApprovedPassIssued;

  /// No description provided for @driverRouteTimeline.
  ///
  /// In en, this message translates to:
  /// **'ROUTE TIMELINE'**
  String get driverRouteTimeline;

  /// No description provided for @driverStopsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} STOPS'**
  String driverStopsCount(Object count);

  /// No description provided for @driverBoardingStatus.
  ///
  /// In en, this message translates to:
  /// **'BOARDING STATUS'**
  String get driverBoardingStatus;

  /// No description provided for @driverBoardingInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap the BOARD button next to each employee to check them in upon boarding the bus.'**
  String get driverBoardingInstruction;

  /// No description provided for @driverBoardedRatio.
  ///
  /// In en, this message translates to:
  /// **'{boarded} of {total} Boarded'**
  String driverBoardedRatio(Object boarded, Object total);

  /// No description provided for @driverVehicleReady.
  ///
  /// In en, this message translates to:
  /// **'VEHICLE READY FOR DISPATCH'**
  String get driverVehicleReady;

  /// No description provided for @driverInspectionInProgress.
  ///
  /// In en, this message translates to:
  /// **'INSPECTION IN PROGRESS'**
  String get driverInspectionInProgress;

  /// No description provided for @driverInspectionProgressText.
  ///
  /// In en, this message translates to:
  /// **'{passed} of {total} checks passed. Complete safety protocol before departure.'**
  String driverInspectionProgressText(Object passed, Object total);

  /// No description provided for @driverPreTripChecklist.
  ///
  /// In en, this message translates to:
  /// **'PRE-TRIP SAFETY CHECKLIST'**
  String get driverPreTripChecklist;

  /// No description provided for @driverStopOfTotal.
  ///
  /// In en, this message translates to:
  /// **'STOP {current} OF {total}'**
  String driverStopOfTotal(Object current, Object total);

  /// No description provided for @driverFinalDestination.
  ///
  /// In en, this message translates to:
  /// **'FINAL DESTINATION'**
  String get driverFinalDestination;

  /// No description provided for @driverStartTripOpenManifest.
  ///
  /// In en, this message translates to:
  /// **'Start Trip & Open Manifest'**
  String get driverStartTripOpenManifest;

  /// No description provided for @driverArrivedAtNextStop.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Next Stop'**
  String get driverArrivedAtNextStop;

  /// No description provided for @driverRouteCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Route Completed Successfully'**
  String get driverRouteCompletedSuccess;

  /// No description provided for @driverReturnToAdminConsole.
  ///
  /// In en, this message translates to:
  /// **'Return to Admin Console'**
  String get driverReturnToAdminConsole;

  /// No description provided for @adminOperationsTitle.
  ///
  /// In en, this message translates to:
  /// **'AlexBank Operations'**
  String get adminOperationsTitle;

  /// No description provided for @adminCentralMobilityConsole.
  ///
  /// In en, this message translates to:
  /// **'CENTRAL MOBILITY CONSOLE'**
  String get adminCentralMobilityConsole;

  /// No description provided for @adminSwitchToEmployeeView.
  ///
  /// In en, this message translates to:
  /// **'Switch to Employee View'**
  String get adminSwitchToEmployeeView;

  /// No description provided for @adminExitToAccessGate.
  ///
  /// In en, this message translates to:
  /// **'Exit to Access Gate'**
  String get adminExitToAccessGate;

  /// No description provided for @adminSchedule.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULE'**
  String get adminSchedule;

  /// No description provided for @adminCaptainAndVehicle.
  ///
  /// In en, this message translates to:
  /// **'CAPTAIN & VEHICLE'**
  String get adminCaptainAndVehicle;

  /// No description provided for @adminSyncMirroredReturnEveningLine.
  ///
  /// In en, this message translates to:
  /// **'Sync Mirrored Return Evening Line'**
  String get adminSyncMirroredReturnEveningLine;

  /// No description provided for @adminGeneratedMirroredReturnNotice.
  ///
  /// In en, this message translates to:
  /// **'Generated mirrored return route starting from Smart Village (HQ) back to departure stops.'**
  String get adminGeneratedMirroredReturnNotice;

  /// No description provided for @adminStationsAndTimetable.
  ///
  /// In en, this message translates to:
  /// **'STATIONS & TIMETABLE'**
  String get adminStationsAndTimetable;

  /// No description provided for @adminAddStationTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Station'**
  String get adminAddStationTitle;

  /// No description provided for @adminStationNameEn.
  ///
  /// In en, this message translates to:
  /// **'Station Name (EN)'**
  String get adminStationNameEn;

  /// No description provided for @adminStationNameAr.
  ///
  /// In en, this message translates to:
  /// **'Station Name (AR)'**
  String get adminStationNameAr;

  /// No description provided for @adminScheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get adminScheduledTime;

  /// No description provided for @adminEditTiming.
  ///
  /// In en, this message translates to:
  /// **'Edit Timing'**
  String get adminEditTiming;

  /// No description provided for @adminMonthlyParkingRate.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY PARKING SUBSCRIPTION RATE'**
  String get adminMonthlyParkingRate;

  /// No description provided for @adminDynamicPricing.
  ///
  /// In en, this message translates to:
  /// **'Admin Dynamic Pricing'**
  String get adminDynamicPricing;

  /// No description provided for @adminCurrentTariff.
  ///
  /// In en, this message translates to:
  /// **'CURRENT TARIFF'**
  String get adminCurrentTariff;

  /// No description provided for @adminEgpMonth.
  ///
  /// In en, this message translates to:
  /// **'EGP/mo'**
  String get adminEgpMonth;

  /// No description provided for @adminFacilityCapacityOverview.
  ///
  /// In en, this message translates to:
  /// **'FACILITY CAPACITY OVERVIEW'**
  String get adminFacilityCapacityOverview;

  /// No description provided for @adminTotalSlots.
  ///
  /// In en, this message translates to:
  /// **'TOTAL SLOTS'**
  String get adminTotalSlots;

  /// No description provided for @adminWaitlist.
  ///
  /// In en, this message translates to:
  /// **'WAITLIST'**
  String get adminWaitlist;

  /// No description provided for @adminActiveCorporateParkingPasses.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE CORPORATE PARKING PASSES'**
  String get adminActiveCorporateParkingPasses;

  /// No description provided for @adminAssignedBay.
  ///
  /// In en, this message translates to:
  /// **'ASSIGNED BAY'**
  String get adminAssignedBay;

  /// No description provided for @adminPresenceStatus.
  ///
  /// In en, this message translates to:
  /// **'PRESENCE STATUS'**
  String get adminPresenceStatus;

  /// No description provided for @adminInsideFacility.
  ///
  /// In en, this message translates to:
  /// **'Inside Facility'**
  String get adminInsideFacility;

  /// No description provided for @adminOutside.
  ///
  /// In en, this message translates to:
  /// **'Outside'**
  String get adminOutside;

  /// No description provided for @adminSetDynamicFeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Dynamic Monthly Parking Fee'**
  String get adminSetDynamicFeeTitle;

  /// No description provided for @adminUpdateRate.
  ///
  /// In en, this message translates to:
  /// **'Update Rate'**
  String get adminUpdateRate;

  /// No description provided for @adminExecutiveFleetOverview.
  ///
  /// In en, this message translates to:
  /// **'EXECUTIVE FLEET OVERVIEW'**
  String get adminExecutiveFleetOverview;

  /// No description provided for @adminAvailableCarsCount.
  ///
  /// In en, this message translates to:
  /// **'{available} / {total} AVAILABLE'**
  String adminAvailableCarsCount(Object available, Object total);

  /// No description provided for @adminMissionRequestManifest.
  ///
  /// In en, this message translates to:
  /// **'MISSION REQUEST MANIFEST'**
  String get adminMissionRequestManifest;

  /// No description provided for @adminTotalCaptains.
  ///
  /// In en, this message translates to:
  /// **'TOTAL CAPTAINS'**
  String get adminTotalCaptains;

  /// No description provided for @adminOnActiveDuty.
  ///
  /// In en, this message translates to:
  /// **'ON ACTIVE DUTY'**
  String get adminOnActiveDuty;

  /// No description provided for @adminAvgRating.
  ///
  /// In en, this message translates to:
  /// **'AVG RATING'**
  String get adminAvgRating;

  /// No description provided for @adminOfficialCaptains.
  ///
  /// In en, this message translates to:
  /// **'OFFICIAL TRANSPORTATION CAPTAINS'**
  String get adminOfficialCaptains;

  /// No description provided for @adminAssignment.
  ///
  /// In en, this message translates to:
  /// **'ASSIGNMENT'**
  String get adminAssignment;

  /// No description provided for @adminActiveInviteCodes.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE INVITE CODES'**
  String get adminActiveInviteCodes;

  /// No description provided for @adminGenerateInviteCode.
  ///
  /// In en, this message translates to:
  /// **'GENERATE ACCESS INVITE CODE'**
  String get adminGenerateInviteCode;

  /// No description provided for @adminSelectAssignedRole.
  ///
  /// In en, this message translates to:
  /// **'Select Assigned Role'**
  String get adminSelectAssignedRole;

  /// No description provided for @adminInternalDepartment.
  ///
  /// In en, this message translates to:
  /// **'Internal Department'**
  String get adminInternalDepartment;

  /// No description provided for @adminAdministrativeNotes.
  ///
  /// In en, this message translates to:
  /// **'Administrative Notes'**
  String get adminAdministrativeNotes;

  /// No description provided for @adminGenerateCode.
  ///
  /// In en, this message translates to:
  /// **'Generate Code'**
  String get adminGenerateCode;

  /// No description provided for @adminKeepRequest.
  ///
  /// In en, this message translates to:
  /// **'Keep Request'**
  String get adminKeepRequest;

  /// No description provided for @adminCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get adminCancelRequest;

  /// No description provided for @driverRouteNumber.
  ///
  /// In en, this message translates to:
  /// **'ROUTE {number}'**
  String driverRouteNumber(Object number);

  /// No description provided for @driverStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get driverStatusCompleted;

  /// No description provided for @driverStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get driverStatusInProgress;

  /// No description provided for @driverStatusScheduled.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULED'**
  String get driverStatusScheduled;

  /// No description provided for @driverPlate.
  ///
  /// In en, this message translates to:
  /// **'Plate: {plate}'**
  String driverPlate(Object plate);

  /// No description provided for @driverCompleteTripAction.
  ///
  /// In en, this message translates to:
  /// **'Complete Trip'**
  String get driverCompleteTripAction;

  /// No description provided for @driverCheckTiresTitle.
  ///
  /// In en, this message translates to:
  /// **'Tires & Pressure'**
  String get driverCheckTiresTitle;

  /// No description provided for @driverCheckTiresDesc.
  ///
  /// In en, this message translates to:
  /// **'All tires inspected for pressure, tread depth, and wheel lug nuts.'**
  String get driverCheckTiresDesc;

  /// No description provided for @driverCheckFuelTitle.
  ///
  /// In en, this message translates to:
  /// **'Fuel / Battery Level'**
  String get driverCheckFuelTitle;

  /// No description provided for @driverCheckFuelDesc.
  ///
  /// In en, this message translates to:
  /// **'Fuel tank above 75% or EV battery adequately charged for route.'**
  String get driverCheckFuelDesc;

  /// No description provided for @driverCheckFirstAidTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency First Aid Kit & Extinguisher'**
  String get driverCheckFirstAidTitle;

  /// No description provided for @driverCheckFirstAidDesc.
  ///
  /// In en, this message translates to:
  /// **'Fire extinguisher certified, first aid medical pouch fully stocked.'**
  String get driverCheckFirstAidDesc;

  /// No description provided for @driverCheckAcTitle.
  ///
  /// In en, this message translates to:
  /// **'Climate Control & AC'**
  String get driverCheckAcTitle;

  /// No description provided for @driverCheckAcDesc.
  ///
  /// In en, this message translates to:
  /// **'Cabin air conditioning and ventilation functioning at 21°C.'**
  String get driverCheckAcDesc;

  /// No description provided for @driverCheckMirrorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mirrors & Rearview Cameras'**
  String get driverCheckMirrorsTitle;

  /// No description provided for @driverCheckMirrorsDesc.
  ///
  /// In en, this message translates to:
  /// **'Side view mirrors adjusted, backup camera sensor clean.'**
  String get driverCheckMirrorsDesc;

  /// No description provided for @driverCheckCleanlinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Interior Cleanliness & Sanitization'**
  String get driverCheckCleanlinessTitle;

  /// No description provided for @driverCheckCleanlinessDesc.
  ///
  /// In en, this message translates to:
  /// **'Passenger seats sanitized, aisles clean, waste receptacles emptied.'**
  String get driverCheckCleanlinessDesc;

  /// No description provided for @adminDeptSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Dept: {dept} • Supervisor: {supervisor}'**
  String adminDeptSupervisor(Object dept, Object supervisor);

  /// No description provided for @adminPurposeWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Purpose: {purpose}'**
  String adminPurposeWithDetails(Object purpose);

  /// No description provided for @driverLicensePhone.
  ///
  /// In en, this message translates to:
  /// **'License: {license} • {phone}'**
  String driverLicensePhone(Object license, Object phone);

  /// No description provided for @adminAssignedVehicle.
  ///
  /// In en, this message translates to:
  /// **'ASSIGNED VEHICLE'**
  String get adminAssignedVehicle;

  /// No description provided for @adminPleaseFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in Name, ISL, and Password'**
  String get adminPleaseFillRequiredFields;

  /// No description provided for @adminProvisionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Admin {name} ({isl}) provisioned successfully!'**
  String adminProvisionSuccess(Object isl, Object name);

  /// No description provided for @adminTargetRole.
  ///
  /// In en, this message translates to:
  /// **'TARGET ROLE'**
  String get adminTargetRole;

  /// No description provided for @adminDeptUses.
  ///
  /// In en, this message translates to:
  /// **'Dept: {dept} • Uses: {uses}'**
  String adminDeptUses(Object dept, Object uses);

  /// No description provided for @adminPickupLabel.
  ///
  /// In en, this message translates to:
  /// **'PICKUP'**
  String get adminPickupLabel;

  /// No description provided for @adminDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'DESTINATION'**
  String get adminDestinationLabel;

  /// No description provided for @adminDeptOnly.
  ///
  /// In en, this message translates to:
  /// **'Dept: {dept}'**
  String adminDeptOnly(Object dept);

  /// No description provided for @registerCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Register New Account'**
  String get registerCardTitle;

  /// No description provided for @registerCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your Bank Transit profile to reserve buses, parking, or errand cars.'**
  String get registerCardSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Haitham Adel'**
  String get fullNameHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PASSWORD'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get confirmPasswordHint;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register & Sign In'**
  String get registerButton;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get haveAccountPrompt;

  /// No description provided for @notHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register Now'**
  String get notHaveAccountPrompt;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @accountNotFoundPleaseRegister.
  ///
  /// In en, this message translates to:
  /// **'Account with ISL {isl} not found. Please register first.'**
  String accountNotFoundPleaseRegister(Object isl);

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account for {name} registered successfully!'**
  String accountCreatedSuccess(Object name);

  /// No description provided for @enableBiometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login'**
  String get enableBiometricTitle;

  /// No description provided for @enableBiometricMessage.
  ///
  /// In en, this message translates to:
  /// **'Enable Face ID or Fingerprint authentication for fast and secure one-touch access to AlexBank Transit.'**
  String get enableBiometricMessage;

  /// No description provided for @enableButton.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric'**
  String get enableButton;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipButton;

  /// No description provided for @loginWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Biometrics'**
  String get loginWithBiometrics;

  /// No description provided for @biometricAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to access AlexBank Transit'**
  String get biometricAuthReason;

  /// No description provided for @biometricEnabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication enabled successfully!'**
  String get biometricEnabledSuccess;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not supported or set up on this device.'**
  String get biometricNotAvailable;

  /// No description provided for @biometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication cancelled or failed.'**
  String get biometricFailed;

  /// No description provided for @biometricCredentialsNotFound.
  ///
  /// In en, this message translates to:
  /// **'No saved biometric credentials found. Please sign in with your ISL.'**
  String get biometricCredentialsNotFound;

  /// No description provided for @noInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetTitle;

  /// No description provided for @noInternetMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your network settings and try again to access AlexBank Transit.'**
  String get noInternetMessage;

  /// No description provided for @tryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// No description provided for @checkingConnection.
  ///
  /// In en, this message translates to:
  /// **'Checking Connection...'**
  String get checkingConnection;

  /// No description provided for @stillNoConnection.
  ///
  /// In en, this message translates to:
  /// **'Still no internet connection. Please verify Wi-Fi or Mobile Data.'**
  String get stillNoConnection;

  /// No description provided for @connectionRestored.
  ///
  /// In en, this message translates to:
  /// **'Internet connection restored.'**
  String get connectionRestored;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
