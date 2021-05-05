/**
 * View | Setup | Staff Scheduling Notifications 
 * @package      Setup
 * @author       Pankaj Karpe
 * @since        30-04-2021
 */

 import React, { Component } from 'react';
 import { connect } from 'react-redux';
 import './StaffSchedulingNotifications.css';
 import TitleTextAndComponentWrapper from './TitleTextAndComponentWrapper.jsx';
 import ToogleButton from "components/Common/ToogleButton/ToogleButton.jsx";
 import NumberInput from 'components/Common/NumberInput.jsx';
 import RadioField from "components/Common/RadioField.jsx";
 import MultiSelectNestedCombobox from 'components/Common/Combobox/MultiSelectNestedCombobox.jsx';
 import ConfirmationBox from 'components/Common/ConfirmationBox.jsx';
 
 
 
 class StaffSchedulingNotifications extends Component {
     constructor(props) {
         super(props);
         this.state = {
             renderFormData: null
         };
         this.reminderTimePickerRef = React.createRef();
         this.formData = {
             notificationMethods: {
                 text: "1",
                 email: "1"
             },
             postShiftNotification: {
                 event: "1"
             },
             lockShiftforEventNotification: {
                 event: "1"
             },
             publishShiftNotification: {
                 event247: "1",
                 event: "1"
             },
             changetoShiftNotification: {
                 event247: "1",
                 event: "1"
             },
             openShiftNotification: {
                 event247: "1",
                 sentToEmployee: "1"
             },
             shiftReminder: {
                 event: "1",
                 before: 60,
                 beforeUnit: "MINS",
                 reportTime: "1",
                 shiftTime: 0
             },
             weeklyOutlookNotification: {
                 event: "1",
                 reminderDay: "monday",
                 reminderTime: "12:00"
             },
             missedClockInReminder: {
                 event: "1",
                 event247: "1",
                 after: 5,
                 beforeUnit: "MINS",
                 reportTime: "1",
                 shiftTime: 0
             },
             missedClockOutReminder: {
                 event: "1",
                 event247: "1",
                 after: 5,
                 beforeUnit: "MINS"
             },
             eventAvailabilityConfirmation: {
                 event: "1"
             },
             eventAvailabilityReminder: {
                 event: "1",
                 before: 5,
                 beforeUnit: "DAYS",
                 reminderTime: "12:00"
             },
             skillExpirationReminder: {
                 event: "1",
                 event247: "1",
                 before: 30,
                 beforeUnit: "DAYS",
                 reminderTime: "12:00"
             },
             confirmReminder: {
                 event: "1",
                 before: 5,
                 beforeUnit: "DAYS",
                 reminderTime: "12:00"
             }
 
         };
 
         this.refsArray = [];
         this.firstTimeLoad = false;
     }
 
     componentDidMount() {
         let me = this;
 
         let mainParentDetails = {};
         mainParentDetails.showSaveCancelButton = true;
         mainParentDetails.saveClick = [{ onClick: this.onSaveButtonClick }];
         mainParentDetails.cancelClick = [{ onClick: this.onCancelButtonClick }];
         mainParentDetails.link = '/setup-navigation/staff-scheduling-module-settings';
         mainParentDetails.breadcrumblinks = [{ link: "/", label: lang("HOME", "Home") }, { link: "/setup", label: lang("SETUP", "Setup") }, { last: true, label: lang("STAFF_SCHEDULING_NOTIFICATIONS", "Staff Scheduling Notifications") }];
 
         me.props.changeBreadCrumData(mainParentDetails);
 
         setTimeout(() => { // temporary added for showing loader scenario
 
             me.getNotificationData();
         }, 500)
     }
     getNotificationData = () => {
         let me = this;
 
         // if already setting is present 
         // then assign me.formData =  response.data
         // IF response.length == 0 then firstTimeLoad flag gets turn to true
         me.firstTimeLoad = true;
         me.setState({
             renderFormData: me.generateRenderUI()
         }, () => {
             me.setValues()
         })
 
 
         return;
 
         // Ajax api        
         $.ajax({
             type: "POST",
             url: BASEURL + "/staffScheduling/Notification/get",
             dataType: 'json',
             async: false,
             data: {
                 data: JSON.stringify(params)
             },
             success: function (response) {
                 if (response.length == 0) {
                     me.firstTimeLoad = true;
                 } else {
                     me.formData = response.data;
                 }
                 me.setState({
                     renderFormData: me.generateRenderUI()
                 }, () => {
                     me.setValues()
                 })
             },
             error: function () {
                 notification({ message: lang("SOMETHING_WENT_WRONG", "Something went wrong"), type: 'danger' });
             }
         });
     }
 
     setValues() {
         let me = this;
         for (const field in me.formData) {
             if (Object.hasOwnProperty.call(me.formData, field)) {
                 switch (field) {
                     case "notificationMethods":
                         if (me.refsArray[field + "~||247||~TextRef"] && me.formData[field].text) {
                             me.refsArray[field + "~||247||~TextRef"].current.setOn();
                         }
                         if (me.refsArray[field + "~||247||~EmailRef"] && me.formData[field].email) {
                             me.refsArray[field + "~||247||~EmailRef"].current.setOn();
                         }
                         break;
                     case "postShiftNotification":
                     case "lockShiftforEventNotification":
                     case "publishShiftNotification":
                     case "changetoShiftNotification":
                     case "eventAvailabilityConfirmation":
                         if (me.refsArray[field + "~||247||~EventRef"] && me.formData[field].event) {
                             me.refsArray[field + "~||247||~EventRef"].current.setOn();
                         }
                         if (me.refsArray[field + "~||247||~247Ref"] && me.formData[field].event247) {
                             me.refsArray[field + "~||247||~247Ref"].current.setOn();
                         }
                         break;
                     case "openShiftNotification":
                         if (me.refsArray[field + "~||247||~247Ref"] && me.formData[field].event247) {
                             me.refsArray[field + "~||247||~247Ref"].current.setOn();
                         }
                         if (me.refsArray[field + "~||247||~SentToEmpRef"] && me.formData[field].sentToEmployee) {
                             me.refsArray[field + "~||247||~SentToEmpRef"].current.setOn();
                         }
                         break;
                     case "shiftReminder":
                         if (me.refsArray[field + "~||247||~EventRef"] && me.formData[field].event) {
                             me.refsArray[field + "~||247||~EventRef"].current.setOn();
                         }
                         if (me.refsArray[field + "~||247||~BeforeRef"]) {
                             me.refsArray[field + "~||247||~BeforeRef"].current.val(me.formData[field].before);
                         }
                         if (me.refsArray[field + "~||247||~ShiftTimeRef"] && me.formData[field].shiftTime) {
                             me.refsArray[field + "~||247||~ShiftTimeRef"].current.check();
                         } else if (me.refsArray[field + "~||247||~ReportTimeRef"]) {
                             me.refsArray[field + "~||247||~ReportTimeRef"].current.check();
                         }
                         break;
                     case "weeklyOutlookNotification":
                         if (me.refsArray[field + "~||247||~EventRef"] && me.formData[field].event) {
                             me.refsArray[field + "~||247||~EventRef"].current.setOn();
                         }
 
                         if (me.refsArray[field + "~||247||~DayRef"] && me.formData[field].reminderDay) {
                             me.refsArray[field + "~||247||~DayRef"].current.setValue(me.formData[field].reminderDay);
                         }
                         if (me.refsArray[field + "~||247||~reminderTimeRef"]) {
                             // set value
                             // me.refsArray[field + "~||247||~reminderTimeRef"].current.setValue(me.formData[field].reminderTime);
                         }
                         break;
                     case "missedClockInReminder":
                         if (me.refsArray[field + "~||247||~EventRef"] && me.formData[field].event) {
                             me.refsArray[field + "~||247||~EventRef"].current.setOn();
                         }
                         if (me.refsArray[field + "~||247||~247Ref"] && me.formData[field].event247) {
                             me.refsArray[field + "~||247||~247Ref"].current.setOn();
                         }
                         if (me.refsArray[field + "~||247||~AfterRef"]) {
                             me.refsArray[field + "~||247||~AfterRef"].current.val(me.formData[field].after);
                         }
                         if (me.refsArray[field + "~||247||~ShiftTimeRef"] && me.formData[field].shiftTime) {
                             me.refsArray[field + "~||247||~ShiftTimeRef"].current.check();
                         } else if (me.refsArray[field + "~||247||~ReportTimeRef"]) {
                             me.refsArray[field + "~||247||~ReportTimeRef"].current.check();
                         }
                         break;
                     case "missedClockOutReminder":
                         if (me.refsArray[field + "~||247||~EventRef"] && me.formData[field].event) {
                             me.refsArray[field + "~||247||~EventRef"].current.setOn();
                         }
                         if (me.refsArray[field + "~||247||~247Ref"] && me.formData[field].event247) {
                             me.refsArray[field + "~||247||~247Ref"].current.setOn();
                         }
                         if (me.refsArray[field + "~||247||~AfterRef"]) {
                             me.refsArray[field + "~||247||~AfterRef"].current.val(me.formData[field].after);
                         }
                         break;
                     case "eventAvailabilityReminder":
                         if (me.refsArray[field + "~||247||~EventRef"] && me.formData[field].event) {
                             me.refsArray[field + "~||247||~EventRef"].current.setOn();
                         }
                         if (me.refsArray[field + "~||247||~BeforeRef"]) {
                             me.refsArray[field + "~||247||~BeforeRef"].current.val(me.formData[field].before);
                         }
                         if (me.refsArray[field + "~||247||~reminderTimeRef"]) {
                             // set value
                             // me.refsArray[field + "~||247||~reminderTimeRef"].current.setValue(me.formData[field].reminderTime);
                         }
                         break;
                     case "skillExpirationReminder":
                         if (me.refsArray[field + "~||247||~EventRef"] && me.formData[field].event) {
                             me.refsArray[field + "~||247||~EventRef"].current.setOn();
                         }
                         if (me.refsArray[field + "~||247||~247Ref"] && me.formData[field].event247) {
                             me.refsArray[field + "~||247||~247Ref"].current.setOn();
                         }
                         if (me.refsArray[field + "~||247||~BeforeRef"]) {
                             me.refsArray[field + "~||247||~BeforeRef"].current.val(me.formData[field].before);
                         }
                         if (me.refsArray[field + "~||247||~reminderTimeRef"]) {
                             // set value
                             // me.refsArray[field + "~||247||~reminderTimeRef"].current.setValue(me.formData[field].reminderTime);
                         }
                         break;
                     case "confirmReminder":
                         if (me.refsArray[field + "~||247||~EventRef"] && me.formData[field].event) {
                             me.refsArray[field + "~||247||~EventRef"].current.setOn();
                         }
                         if (me.refsArray[field + "~||247||~BeforeRef"]) {
                             me.refsArray[field + "~||247||~BeforeRef"].current.val(me.formData[field].before);
                         }
                         if (me.refsArray[field + "~||247||~reminderTimeRef"]) {
                             // set value
                             // me.refsArray[field + "~||247||~reminderTimeRef"].current.setValue(me.formData[field].reminderTime);
                         }
                         break;
 
                     default:
                         break;
                 }
             }
         }
     }
 
     createRefsForCompoent = (fieldName) => {
         let me = this;
         let createRef = React.createRef();
         me.refsArray[fieldName] = createRef;
         return createRef;
     }
 
     notificationToggles = (field) => {
         return (
             <div className={"toggle-buttons-div col-xl-4 col-lg-4 col-md-5 col-sm-6"} style={{ alignItems: "flex-end" }}>
                 <div style={{ display: "flex", alignItems: "center" }}>
                     <label className={"title-div-class"} style={{ paddingRight: "10px" }}>{lang("NOTIFICATION_METHOD", "Notification Method")}</label>
                     <ToogleButton
                         className={"toogle-button"}
                         iconClassName={'icon-size'}
                         ref={this.createRefsForCompoent(field + "~||247||~TextRef")}
                     />
                     <label className={"title-div-class"} style={{ paddingLeft: "6px", paddingRight: "15px" }}>{lang("TEXT", "Text")}</label>
                     <ToogleButton
                         className={"toogle-button"}
                         iconClassName={'icon-size'}
                         ref={this.createRefsForCompoent(field + "~||247||~EmailRef")}
                     />
                     <label className={"title-div-class"} style={{ paddingLeft: "6px" }}>{lang("EMAIL", "Email")}</label>
                 </div>
             </div>
         );
 
     }
 
     notificationSeparator = () => {
         return <div className={"notification-seperator-class"}>
             <label className={"title-div-class"} >{lang("24/7", "24/7")}</label>
             <span style={{ paddingLeft: "20px", paddingRight: "13px", color: "#D9DCDE" }}>|</span>
             <label className={"title-div-class"} style={{ paddingLeft: "6px" }}>{lang("EVENT", "Event")}</label>
         </div>
     }
 
     eventAnd247Toggles = (field = null, toggle247 = true, toggleEvent = true) => {
         if (!field) return null;
 
         let toggleonly247Class = toggleEvent ? "toggle247" : "onlyToggle247";
         return (
             <div className={"toggle-buttons-div  col-xl-3 col-lg-4 col-md-5 col-sm-6"}>
                 {
                     toggle247 ? <ToogleButton
                         className={"toogle-button " + toggleonly247Class}
                         iconClassName={'icon-size'}
                         ref={this.createRefsForCompoent(field + "~||247||~247Ref")}
                     /> : null
                 }
                 {
                     toggleEvent ? <ToogleButton
                         className={"toogle-button toggleEvent"}
                         iconClassName={'icon-size'}
                         ref={this.createRefsForCompoent(field + "~||247||~EventRef")}
                     /> : null
                 }
 
 
             </div>
         );
 
     }
 
     openShiftNotificationSentTo = (field) => {
         return <div className="open-shift-sent-to-class ">
             <label className={"text-label-class"} style={{ paddingRight: "10px" }} >{lang("SEND_TO_SCHEDULED_EMPLOYEES", "Send to Scheduled Employees")}</label>
             <div className="toggle-buttons-div">
                 <ToogleButton
                     className={"toogle-button"}
                     iconClassName={'icon-size'}
                     ref={this.createRefsForCompoent(field + "~||247||~SentToEmpRef")}
                 />
             </div>
         </div>
     }
 
     shiftReminderBeforeAndEventReminder = (field) => {
         return (
             <div className="d-flex" style={{ paddingBottom: '5px' }}>
                 <div style={{ display: "block" }}>
                     <label className="text-label-class" style={{ paddingBottom: "2px" }}>{lang("BEFORE", "Before")}</label>
                     <div className="number-with-text-div">
                         <div className="number-field-class-name">
                             <NumberInput
                                 id="shiftReminderBefore"
                                 ref={this.createRefsForCompoent(field + "~||247||~BeforeRef")}
                                 className="shift-reminder-before"
                                 min={0}
                                 max={999}
                                 allowArrowKeys={true}
                                 showArrowKeys={true}
                             />
                         </div>
                         <label className="text-label-class" style={{ paddingLeft: "7px" }}>{lang("MMINS", "mins")}</label>
                     </div>
                 </div>
                 <div style={{ display: "block" }}>
                     <label className="text-label-class" style={{ paddingLeft: "20px", paddingBottom: "5px" }}>{lang("EVENT_REMINDER", "Event Reminder")}</label>
                     <div className="row margin-0 ss-notification-radio-buttons">
                         <RadioField
                             id={'shiftEventReminderReportTime'}
                             ref={this.createRefsForCompoent(field + "~||247||~ReportTimeRef")}
                             name={'shiftEventReminder'}
                             label={lang('REPORT_TIME', 'Report Time')}
                             padding={'0px 10px 0px 20px'}
                             className={'radio-fields'}
                         />
                         <RadioField
                             id={'shiftEventReminderShiftTime'}
                             ref={this.createRefsForCompoent(field + "~||247||~ShiftTimeRef")}
                             name={'shiftEventReminder'}
                             defaultChecked={false}
                             label={lang('SHIFT_TIME', 'Shift Time')}
                             padding={'0px 10px 0px 10px'}
                             className={'radio-fields'}
                         />
                     </div>
                 </div>
             </div>
         );
     }
 
     weeklyOutlookReminderComponent = (field) => {
         return (
             <div className="d-flex" style={{ paddingBottom: '5px' }}>
                 <div style={{ display: "block" }}>
                     <label className="text-label-class" style={{ paddingBottom: "2px" }}>{lang("REMINDER_DAY", "Reminder Day")}</label>
                     <div className="ss-notification-dropdown-class-name">
                         <MultiSelectNestedCombobox
                             ref={this.createRefsForCompoent(field + "~||247||~DayRef")}
                             width={'98px'}
                             placeholder={'Select'}
                             source={[
                                 {
                                     id: 'monday',
                                     value: lang('MONDAY', "Monday")
                                 },
                                 {
                                     id: 'tuesday',
                                     value: lang('TUESDAY', "Tuesday")
                                 },
                                 {
                                     id: 'wednesday',
                                     value: lang('WEDNESDAY', "Wednesday")
                                 },
                                 {
                                     id: 'thursday',
                                     value: lang('THURSDAY', "Thursday")
                                 },
                                 {
                                     id: 'friday',
                                     value: lang('FRIDAY', "Friday")
                                 },
                                 {
                                     id: 'saturday',
                                     value: lang('SATURDAY', "Saturday")
                                 },
                                 {
                                     id: 'sunday',
                                     value: lang('SUNDAY', "Sunday")
                                 }
                             ]}
                             multiSelect={false}
                             className="weekly-reminder-ss-notify-drown-padding"
                             isReadonly={true}
                         />
                     </div>
                 </div>
                 <div style={{ display: "block" }}>
                     <label className="text-label-class" style={{ paddingLeft: "20px", paddingBottom: "5px" }}>{lang("REMINDER_TIME", "Reminder Time")}</label>
                     <div className="row margin-0 ss-notification-radio-buttons">
                         {/* <PopoverTimePicker
                         id={`reminder-time-time-picker`}
                         ref={this.createRefsForCompoent(field + "~||247||~reminderTimeRef")}
                         onClick={() => { }}
                         onClear={(e) => {
                             // this.onTimePickerClicked(e)
                             // this.validateData()
                         }}
                         onSaveClick={() => { }}
                     /> */}
                     </div>
                 </div>
             </div>
         );
     }
 
     eventAvailabilityReminderComponent = (field) => {
         return (
             <div className="d-flex" style={{ paddingBottom: '5px' }}>
                 <div style={{ display: "block" }}>
                     <label className="text-label-class" style={{ paddingBottom: "2px" }}>{lang("BEFORE", "Before")}</label>
                     <div className="number-with-text-div">
                         <div className="number-field-class-name">
                             <NumberInput
                                 id="eventAvailabilityReminderBefore"
                                 ref={this.createRefsForCompoent(field + "~||247||~BeforeRef")}
                                 className="event-availability-reminder-before"
                                 min={0}
                                 max={999}
                                 allowArrowKeys={true}
                                 showArrowKeys={true}
                             />
                         </div>
                         <label className="text-label-class" style={{ paddingLeft: "7px" }}>{lang("DAYS", "days")}</label>
                     </div>
                 </div>
                 <div style={{ display: "block" }}>
                     <label className="text-label-class" style={{ paddingLeft: "20px", paddingBottom: "5px" }}>{lang("REMINDER_TIME", "Reminder Time")}</label>
                     <div className="row margin-0 ss-notification-radio-buttons">
                         {/* <PopoverTimePicker
                         id={`reminder-time-time-picker`}
                         ref={this.createRefsForCompoent(field + "~||247||~reminderTimeRef")}
                         onClick={() => { }}
                         onClear={(e) => {
                             // this.onTimePickerClicked(e)
                             // this.validateData()
                         }}
                         onSaveClick={() => { }}
                     /> */}
                     </div>
                 </div>
             </div>
         );
     }
     skillExpirtaionReminderComponent = (field) => {
         return (
             <div className="d-flex" style={{ paddingBottom: '5px' }}>
                 <div style={{ display: "block" }}>
                     <label className="text-label-class" style={{ paddingBottom: "2px" }}>{lang("BEFORE", "Before")}</label>
                     <div className="number-with-text-div">
                         <div className="number-field-class-name">
                             <NumberInput
                                 ref={this.createRefsForCompoent(field + "~||247||~BeforeRef")}
                                 id="skillExpirationReminderBefore"
                                 className="skill-expiration-reminder-before"
                                 min={0}
                                 max={999}
                                 allowArrowKeys={true}
                                 showArrowKeys={true}
                             />
                         </div>
                         <label className="text-label-class" style={{ paddingLeft: "7px" }}>{lang("DAYS", "days")}</label>
                     </div>
                 </div>
                 <div style={{ display: "block" }}>
                     <label className="text-label-class" style={{ paddingLeft: "20px", paddingBottom: "5px" }}>{lang("REMINDER_TIME", "Reminder Time")}</label>
                     <div className="row margin-0 ss-notification-radio-buttons">
                         {/* <PopoverTimePicker
                         id={`reminder-time-time-picker`}
                         ref={this.createRefsForCompoent(field + "~||247||~reminderTimeRef")}
                         onClick={() => { }}
                         onClear={(e) => {
                             // this.onTimePickerClicked(e)
                             // this.validateData()
                         }}
                         onSaveClick={() => { }}
                     /> */}
                     </div>
                 </div>
             </div>
         );
     }
     confirmReminderComponent = (field) => {
         return (
             <div className="d-flex" style={{ paddingBottom: '5px' }}>
                 <div style={{ display: "block" }}>
                     <label className="text-label-class" style={{ paddingBottom: "2px" }}>{lang("BEFORE", "Before")}</label>
                     <div className="number-with-text-div">
                         <div className="number-field-class-name">
                             <NumberInput
                                 ref={this.createRefsForCompoent(field + "~||247||~BeforeRef")}
                                 id="confirmReminderBefore"
                                 className="confirm-reminder-before"
                                 min={0}
                                 max={999}
                                 allowArrowKeys={true}
                                 showArrowKeys={true}
                             />
                         </div>
                         <label className="text-label-class" style={{ paddingLeft: "7px" }}>{lang("DAYS", "days")}</label>
                     </div>
                 </div>
                 <div style={{ display: "block" }}>
                     <label className="text-label-class" style={{ paddingLeft: "20px", paddingBottom: "5px" }}>{lang("REMINDER_TIME", "Reminder Time")}</label>
                     <div className="row margin-0 ss-notification-radio-buttons">
                         {/* <PopoverTimePicker
                         id={`reminder-time-time-picker`}
                         ref={this.createRefsForCompoent(field + "~||247||~reminderTimeRef")}
                         onClick={() => { }}
                         onClear={(e) => {
                             // this.onTimePickerClicked(e)
                             // this.validateData()
                         }}
                         onSaveClick={() => { }}
                     /> */}
                     </div>
                 </div>
             </div>
         );
     }
 
 
     missClockInReminderComponent = (field) => {
         return (
             <div className="d-flex" style={{ paddingBottom: '5px' }}>
                 <div style={{ display: "block" }}>
                     <label className="text-label-class" style={{ paddingBottom: "2px" }}>{lang("AFTER", "After")}</label>
                     <div className="number-with-text-div">
                         <div className="number-field-class-name">
                             <NumberInput
                                 id="missedClockedInAfter"
                                 ref={this.createRefsForCompoent(field + "~||247||~AfterRef")}
                                 className="missed-clockedIn-after"
                                 min={0}
                                 max={999}
                                 allowArrowKeys={true}
                                 showArrowKeys={true}
                             />
                         </div>
                         <label className="text-label-class" style={{ paddingLeft: "7px" }}>{lang("MMINS", "mins")}</label>
                     </div>
                 </div>
                 <div style={{ display: "block" }}>
                     <label className="text-label-class" style={{ paddingLeft: "20px", paddingBottom: "5px" }}>{lang("EVENT_REMINDER", "Event Reminder")}</label>
                     <div className="row margin-0 ss-notification-radio-buttons">
                         <RadioField
                             id={'missedClockedInReportTime'}
                             ref={this.createRefsForCompoent(field + "~||247||~ReportTimeRef")}
                             name={'missedClockedInReport'}
                             label={lang('REPORT_TIME', 'Report Time')}
                             padding={'0px 10px 0px 20px'}
                             className={'radio-fields'}
                         />
                         <RadioField
                             id={'missedClockedInShiftTime'}
                             ref={this.createRefsForCompoent(field + "~||247||~ShiftTimeRef")}
                             name={'missedClockedInReport'}
                             label={lang('SHIFT_TIME', 'Shift Time')}
                             padding={'0px 10px 0px 10px'}
                             className={'radio-fields'}
                         />
                     </div>
                 </div>
             </div>
         );
     }
     missClockOutReminderComponent = (field) => {
         return (
             <div style={{ display: "block", paddingBottom: '5px' }}>
                 <label className="text-label-class" style={{ paddingBottom: "2px" }}>{lang("AFTER", "After")}</label>
                 <div className="number-with-text-div">
                     <div className="number-field-class-name">
                         <NumberInput
                             id="missedClockedOutAfter"
                             ref={this.createRefsForCompoent(field + "~||247||~AfterRef")}
                             className="missed-clockedOut-after"
                             min={0}
                             max={999}
                             allowArrowKeys={true}
                             showArrowKeys={true}
                         />
                     </div>
                     <label className="text-label-class" style={{ paddingLeft: "7px" }}>{lang("MMINS", "mins")}</label>
                 </div>
             </div>
         );
     }
 
     generateRenderUI = () => {
         let me = this;
         const renderElementsArr = [
             {
                 mainTextClassName: "notification-outer-div-class col-xl-9 col-lg-8 col-md-7 col-sm-6",
                 labelText: lang("POST_SHIFT_NOTIFICATION", "Post Shift Notification"),
                 text: lang("POST_SHIFT_NOTIFICATION_TEXT", "Automatically send a notification to employees when new shifts post for them to select their availability."),
                 toggleComponent: () => { return me.eventAnd247Toggles("postShiftNotification", false, true) },
                 showLineBreaker: true
             },
             {
                 mainTextClassName: "notification-outer-div-class col-xl-9 col-lg-8 col-md-7 col-sm-6",
                 labelText: lang("LOCK_SHIFT_EVENT_NOTIFICATION", "Lock Shift for Event Notification"),
                 text: lang("LOCK_SHIFT_EVENT_NOTIFICATION_TEXT", "Automatically send a notification to employees once an event locks by notifying them they can make no further event availability changes."),
                 toggleComponent: () => { return me.eventAnd247Toggles("lockShiftforEventNotification", false, true) },
                 showLineBreaker: true
             },
             {
                 mainTextClassName: "notification-outer-div-class col-xl-9 col-lg-8 col-md-7 col-sm-6",
                 labelText: lang("PUBLISH_SHIFT_NOTIFICATION", "Publish Shift Notification"),
                 text: lang("PUBLISH_SHIFT_NOTIFICATION_TEXT", "Automatically send a notification to employees when a shift they are scheduled for has been published."),
                 toggleComponent: () => { return me.eventAnd247Toggles("publishShiftNotification", true, true) },
                 showLineBreaker: true
 
             },
             {
                 mainTextClassName: "notification-outer-div-class col-xl-9 col-lg-8 col-md-7 col-sm-6",
                 labelText: lang("CHANGE_TO_SHIFT_NOTIFICATION", "Change to Shift Notification"),
                 text: lang("CHANGE_TO_SHIFT_NOTIFICATION_TEXT", "Automatically send a notification when there are changes made to an employee's published shift."),
                 toggleComponent: () => { return me.eventAnd247Toggles("changetoShiftNotification", true, true) },
                 showLineBreaker: true
             },
             {
                 mainTextClassName: "notification-outer-div-class col-xl-9 col-lg-8 col-md-7 col-sm-6",
                 labelText: lang("OPEN_SHIFT_NOTIFICATION", "Open Shift Notification"),
                 text: lang("OPEN_SHIFT_NOTIFICATION_TEXT", "Automatically send a notification to employees of published open shifts which are newly created or unassigned."),
                 toggleComponent: () => { return me.eventAnd247Toggles("openShiftNotification", true, false) },
                 otherComponents: () => { return me.openShiftNotificationSentTo("openShiftNotification") },
                 showLineBreaker: true
             },
             {
                 mainTextClassName: "notification-outer-div-class col-xl-9 col-lg-8 col-md-7 col-sm-6",
                 labelText: lang("SHIFT_REMINDER", "Shift Reminder"),
                 text: lang("SHIFT_REMINDER_TEXT", "Automatically send a shift reminder to employees X minutes before starting their shift. Choose to send out a reminder based on the employee's report time or shift time."),
                 toggleComponent: () => { return me.eventAnd247Toggles("shiftReminder", false, true) },
                 otherComponents: () => { return me.shiftReminderBeforeAndEventReminder("shiftReminder") },
                 showLineBreaker: true
             },
             {
                 mainTextClassName: "notification-outer-div-class col-xl-9 col-lg-8 col-md-7 col-sm-6",
                 labelText: lang("WEEKLY_OUTLOOK_NOTIFICATION", "Weekly Outlook Notification"),
                 text: lang("WEEKLY_OUTLOOK_NOTIFICATION_TEXT", "Automatically send a notification of an employee's schedule for the next seven days on a specific day and time every week."),
                 toggleComponent: () => { return me.eventAnd247Toggles("weeklyOutlookNotification", false, true) },
                 otherComponents: () => { return me.weeklyOutlookReminderComponent("weeklyOutlookNotification") },
                 showLineBreaker: true
             },
             {
                 mainTextClassName: "notification-outer-div-class col-xl-9 col-lg-8 col-md-7 col-sm-6",
                 labelText: lang("MISSED_CLOCK_IN_REMINDER", "Missed Clock-In Reminder"),
                 text: lang("MISSED_CLOCK_IN_REMINDER_TEXT", "Automatically send a reminder to employees after X minutes after not clocking in. For event, choose to send out a reminder based on the employee's report time or shift time."),
                 toggleComponent: () => { return me.eventAnd247Toggles("missedClockInReminder", true, true) },
                 otherComponents: () => { return me.missClockInReminderComponent("missedClockInReminder") },
                 showLineBreaker: true
             },
 
             {
                 mainTextClassName: "notification-outer-div-class col-xl-9 col-lg-8 col-md-7 col-sm-6",
                 labelText: lang("MISSED_CLOCK_OUT_REMINDER", "Missed Clock-Out Reminder"),
                 text: lang("MISSED_CLOCK_OUT_REMINDER_TEXT", "Automatically send a reminder to employees after X minutes for not clocking out."),
                 toggleComponent: () => { return me.eventAnd247Toggles("missedClockOutReminder", true, true) },
                 otherComponents: () => { return me.missClockOutReminderComponent("missedClockOutReminder") },
                 showLineBreaker: true
             },
             {
                 mainTextClassName: "notification-outer-div-class col-xl-9 col-lg-8 col-md-7 col-sm-6",
                 labelText: lang("EVENT_AVAILABILITY_CONFIRMATION", "Event Availability Confirmation"),
                 text: lang("EVENT_AVAILABILITY_CONFIRMATION_TEXT", "Automatically send a confirmation to employees once they select their availability for an event."),
                 toggleComponent: () => { return me.eventAnd247Toggles("eventAvailabilityConfirmation", false, true) },
                 showLineBreaker: true
             },
             {
                 mainTextClassName: "notification-outer-div-class col-xl-9 col-lg-8 col-md-7 col-sm-6",
                 labelText: lang("EVENT_AVAILABILITY_REMINDER", "Event Availability Reminder"),
                 text: lang("EVENT_AVAILABILITY_REMINDER_TEXT", "Automatically send a reminder to employees X number of days before the event's lock date at a specific time if they have not submitted their event availability."),
                 toggleComponent: () => { return me.eventAnd247Toggles("eventAvailabilityReminder", false, true) },
                 otherComponents: () => { return me.eventAvailabilityReminderComponent("eventAvailabilityReminder") },
                 showLineBreaker: true
             },
             {
                 mainTextClassName: "notification-outer-div-class col-xl-9 col-lg-8 col-md-7 col-sm-6",
                 labelText: lang("SKILL_EXPIRATION_REMINDER", "Skill Expiration Reminder"),
                 text: lang("SKILL_EXPIRATION_REMINDER_TEXT", "Automatically send a reminder to employees X number of days before their skill expires at a specific time."),
                 toggleComponent: () => { return me.eventAnd247Toggles("skillExpirationReminder", true, true) },
                 otherComponents: () => { return me.skillExpirtaionReminderComponent("skillExpirationReminder") },
                 showLineBreaker: true
             },
             {
                 mainTextClassName: "notification-outer-div-class col-xl-9 col-lg-8 col-md-7 col-sm-6",
                 labelText: lang("CONFIRM_REMINDER", "Confirm Reminder"),
                 text: lang("CONFIRM_REMINDER_TEXT", "Automatically send a reminder to employees X number of days before the event at a specific time that they must confirm before the start of the event."),
                 toggleComponent: () => { return me.eventAnd247Toggles("confirmReminder", false, true) },
                 otherComponents: () => { return me.confirmReminderComponent("confirmReminder") },
                 showLineBreaker: true
             }
         ];
         return (
             <div style={{ height: "calc(100% - 1px)" }} className="staff-schedule-notify-div">
                 <TitleTextAndComponentWrapper
                     wrapperClassName={"wrapper-main-div-class-toggle col-xl-12 col-md-12 col-sm-12 col-12"}
                     mainTextClassName={"notification-outer-div-class col-xl-8 col-lg-8 col-md-7 col-sm-6"}
                     labelText={lang("NOTIFICATIONS", "Notifications")}
                     text={lang("SS_NOTIFICATION_TEXT", "Enabling the options below will automatically send these notifications based on the employee's notification method.")}
                     toggleComponent={me.notificationToggles("notificationMethods")}
                     otherComponents={me.notificationSeparator()}
                 />
 
                 <div className="notification-scroll-div">
                     {
                         renderElementsArr.map((element, index) => {
                             return <TitleTextAndComponentWrapper
                                 key={index}
                                 mainTextClassName={element.mainTextClassName}
                                 labelText={element.labelText}
                                 text={element.text}
                                 toggleComponent={element.toggleComponent()}
                                 otherComponents={element.otherComponents ? element.otherComponents() : null}
                                 showLineBreaker={element.showLineBreaker}
                             />
                         })
                     }
                     <div className="save-cancel-button-section col-lg-12 col-12">
                         <div className="row">
                             <div className="button-div">
                                 <button onClick={me.onCancelButtonClick} className="cancel-button" type="button">{lang("CANCEL", "Cancel")}</button>
                             </div>
                             <div className="button-div">
                                 <button onClick={me.onSaveButtonClick} className="save-button" type="button">{lang("SAVE", "Save")}</button>
                             </div>
                         </div>
                     </div>
                 </div>
             </div >
         );
     }
 
     onSaveButtonClick = () => {
         let me = this;
         let finalData = { ...me.formData };
         let extraAppendedRefskeywords = { '247Ref': "event247", 'EventRef': "event", 'BeforeRef': "before", 'AfterRef': "after", 'ReportTimeRef': "reportTime", 'ShiftTimeRef': "shiftTime", 'EmailRef': "email", 'TextRef': "text", 'SentToEmpRef': "sentToEmployee", 'DayRef': "reminderDay", "reminderTimeRef": "reminderTime" }
         for (const keyRef in me.refsArray) {
             if (Object.hasOwnProperty.call(me.refsArray, keyRef)) {
                 let refSplittedArr = keyRef.split("~||247||~");
                 let temp = refSplittedArr[0];
                 let temp1 = refSplittedArr[1];
                 switch (temp1) {
                     case "247Ref":
                     case "EventRef":
                     case "SentToEmpRef":
                     case "TextRef":
                     case "EmailRef":
                         finalData[temp][extraAppendedRefskeywords[temp1]] = me.refsArray[keyRef].current.value() ? "1" : "0";
                         break;
                     case "BeforeRef":
                     case "AfterRef":
                         finalData[temp][extraAppendedRefskeywords[temp1]] = me.refsArray[keyRef].current.val();
                         break;
                     case "ReportTimeRef":
                     case "ShiftTimeRef":
                         finalData[temp][extraAppendedRefskeywords[temp1]] = me.refsArray[keyRef].current.isChecked() ? "1" : "0";
                         break;
                     case "DayRef":
                         finalData[temp][extraAppendedRefskeywords[temp1]] = me.refsArray[keyRef].current.getSelectedItems()[0] ? me.refsArray[keyRef].current.getSelectedItems()[0].id : "monday";
                         break;
                     case "reminderTimeRef":
                         finalData[temp][extraAppendedRefskeywords[temp1]] = "12:00";
                         // finalData[temp][extraAppendedRefskeywords[temp1]] = me.refsArray[keyRef].current.getSelectedItems()[0] ? me.refsArray[keyRef].current.getSelectedItems()[0].id : "monday";
                         break;
                     default:
                         break;
                 }
             }
         }
         console.log("final_data", finalData)
         // save/update Data ajax will hit here internally
         let url = "/staffScheduling/Notification/update";
         if (me.firstTimeLoad) {
             url = "/staffScheduling/Notification/insert"
         }
 
         // temp added untill API Integration
         notification({
             message: lang("RECORD_HAS_BEEN_UPDATED_SUCCESSFULLY", "Record has been updated successfully"),
             type: 'success'
         })
         me.props.history.push({
             pathname: '/setup'
         });
         return;
 
 
 
         $.ajax({
             type: "POST",
             url: BASEURL + url,
             dataType: 'json',
             async: false,
             data: {
                 data: JSON.stringify(finalData)
             },
             success: function (response) {
                 notification({
                     message: lang("RECORD_HAS_BEEN_UPDATED_SUCCESSFULLY", "Record has been updated successfully"),
                     type: 'success'
                 })
                 me.props.history.push({
                     pathname: '/setup'
                 });
             },
             error: function () {
                 notification({ message: lang("SOMETHING_WENT_WRONG", "Something went wrong"), type: 'danger' });
             }
         });
 
 
     }
 
     onCancelButtonClick = () => {
         let me = this;
 
         let options = {
             onConfirm: () => {
                 me.props.history.push({
                     pathname: '/setup'
                 });
             },
             title: lang("CONFIRMATION", "Confirmation"),
             body: lang("STAFF_SCHEDULE_NOTIFICATION_CANCEL_CONFIRMATION_MESSAGE", "Are you sure you want to cancel? If yes, then changes will not reflect."),
             confirmLabel: lang("YES", "Yes")
         };
         me.refs.ss_schedule_notification_confirmation_box.setOptions(options);
         $("#ss_schedule_notification_confirmation_box").modal("show");
     }
     render() {
         return <div className="ss-notification-area">
             {
                 this.state.renderFormData ? this.state.renderFormData : <div className="loader-content">
                     <div className="page-loading"></div>
                 </div>
             }
             <ConfirmationBox
                 id="ss_schedule_notification_confirmation_box"
                 ref="ss_schedule_notification_confirmation_box"
                 title={lang("CONFIRMATION", "Confirmation")}
                 body={lang("STAFF_SCHEDULE_NOTIFICATION_CANCEL_CONFIRMATION_MESSAGE", "Are you sure you want to cancel? If yes, then changes will not reflect.")}
                 cancelLabel={lang("CANCEL", "Cancel")}
                 confirmLabel={lang("UPDATE", "Update")}
             />
         </div>
     }
 
 
 }
 
 function mapStateToProps(state) {
     return { userData: state.userData }
 }
 
 function mapStateToProps(dispatch) {
     return ({
         changeBreadCrumData: (data) => { dispatch({ type: "BREADCRUMLINK", data: data }) }
     });
 }
 
 export default connect(mapStateToProps, mapStateToProps)(StaffSchedulingNotifications);