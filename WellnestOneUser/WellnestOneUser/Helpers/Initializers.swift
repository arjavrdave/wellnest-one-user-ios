//
//  Initializers.swift
//  SameHere
//
//  Created by Mayank Verma on 23/03/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

class Initializers: NSObject {
    
    public class var shared: Initializers {
        struct Static {
            //Singleton instance. Initializing keyboard manger.
            static let initialize = Initializers()
        }
        
        /** @return Returns the default singleton instance. */
        return Static.initialize
    }
    
    var container: Container {
        let container = Container()
        
        // Register Network Model
        container.register(IBearerToken.self) { (resolver) -> BearerToken in
            return BearerToken()
        }
        container.register(IAuthHandler.self, factory: { (resolver) -> AuthHandler in
            return AuthHandler(bearer: container.resolve(IBearerToken.self)!)
        })
        container.register(IAlamoRequest.self, factory: { (resolver) -> AlamoRequest in
            return AlamoRequest(auth: container.resolve(IAuthHandler.self)!)
        })
        container.register(IStorage.self) { (resolver) -> Storage in
            return Storage(container.resolve(IAlamoRequest.self)!)
        }
        container.register(IUserMedicalHistory.self) { (resolver) -> UserMedicalHistory in
            return UserMedicalHistory(container.resolve(IAlamoRequest.self)!)
        }
        container.register(IRecordings.self) { (resolver) -> Recordings in
            return Recordings(container.resolve(IAlamoRequest.self)!)
        }
        container.register(IPatient.self) { (resolver) -> Patient in
            return Patient(container.resolve(IAlamoRequest.self)!)
        }
        // Register Account Model
        container.register(IAccount.self) { (resolver) -> Account in
            return Account(container.resolve(IAlamoRequest.self)!)
        }
//        container.register(IRecordings.self) { (resolver) -> Recordings in
//            return Recordings(container.resolve(IAlamoRequest.self)!)
//        }
//        container.register(IDoctor.self) { (resolver) -> Doctor in
//            return Doctor(container.resolve(IAlamoRequest.self)!)
//        }


//        container.register(ITechnician.self) { (resolver) -> Technician in
//            return Technician(container.resolve(IAlamoRequest.self)!)
//        }
//        container.register(IOrganisation.self) { (resolver) -> Organisation in
//            return Organisation(container.resolve(IAlamoRequest.self)!)
//        }
        //        container.register(IStorage.self) { (resolver) -> Storage in
        //            return Storage(container.resolve(IAlamoRequest.self)!)
        //        }
//
//        container.register(INotifications.self) { (resolver) -> Notifications in
//            return Notifications(container.resolve(IAlamoRequest.self)!)
//        }
//
//        container.register(UserMedicalHistory.self) { (resolver) -> UserMedicalHistory in
//            return UserMedicalHistory(container.resolve(IAlamoRequest.self)!)
//        }
//        container.register(IUserMedicalHistory.self) { (resolver) -> UserMedicalHistory in
//            return UserMedicalHistory(container.resolve(IAlamoRequest.self)!)
//        }
//
//        // UserStoryBoard Model
//        container.storyboardInitCompleted(RecordingHomeViewController.self) { (resolver, controller) in
//            controller.storage = resolver.resolve(IStorage.self)
//        }
//        container.storyboardInitCompleted(OTPViewController.self) { (resolver, controller) in
//            controller.account = resolver.resolve(IAccount.self)
//            controller.doctor = resolver.resolve(IDoctor.self)
//        }
        container.storyboardInitCompleted(LoginViewController.self) { (resolver, controller) in
            controller.account = resolver.resolve(IAccount.self)
        }
        container.storyboardInitCompleted(CreateProfileViewController.self) { (resolver, controller) in
            controller.account = resolver.resolve(IAccount.self)
            controller.storage = resolver.resolve(IStorage.self)
        }
        container.storyboardInitCompleted(MedicalHistoryViewController.self) { (resolver, controller) in
            controller.account = resolver.resolve(IAccount.self)
            controller.storage = resolver.resolve(IStorage.self)
            controller.medicalHistory = resolver.resolve(IUserMedicalHistory.self)
        }
        
        container.storyboardInitCompleted(ProfileSettingViewController.self) { (resolver, controller) in
            controller.account = resolver.resolve(IAccount.self)
        }
        container.storyboardInitCompleted(PreRecordAssesViewController.self) { (resolver, controller) in
            controller.recording = resolver.resolve(IRecordings.self)
        }
        container.storyboardInitCompleted(PreRecordingConnectionViewController.self) { (resolver, controller) in
            controller.recording = resolver.resolve(IRecordings.self)
        }
        container.storyboardInitCompleted(CheckConnectionViewController.self) { (resolver, controller) in
            controller.recording = resolver.resolve(IRecordings.self)
        }
        container.storyboardInitCompleted(RecordingContinueousViewController.self) { (resolver, controller) in
            controller.recording = resolver.resolve(IRecordings.self)
        }
        container.storyboardInitCompleted(RecordingPreviewViewController.self) { (resolver, controller) in
            controller.recording = resolver.resolve(IRecordings.self)
            controller.storage = resolver.resolve(IStorage.self)
            controller.patient = resolver.resolve(IPatient.self)
        }
        container.storyboardInitCompleted(PairDeviceViewController.self) { (resolver, controller) in
            controller.recording = resolver.resolve(IRecordings.self)
        }
        container.storyboardInitCompleted(HomeViewController.self) { (resolver, controller) in
            controller.recording = resolver.resolve(IRecordings.self)
            controller.storage = resolver.resolve(IStorage.self)
        }
        container.storyboardInitCompleted(GetInTouchViewController.self) { (resolver, controller) in
            controller.patient = resolver.resolve(IPatient.self)
        }
        container.storyboardInitCompleted(ChooseMemberViewController.self) { (resolver, controller) in
            controller.patient = resolver.resolve(IPatient.self)
            controller.recording = resolver.resolve(IRecordings.self)
            controller.account = resolver.resolve(IAccount.self)
            controller.storage = resolver.resolve(IStorage.self)
        }
//        container.storyboardInitCompleted(GetInTouchViewController.self) { (resolver, controller) in
//            controller.account = resolver.resolve(IAccount.self)
//        }
//        container.storyboardInitCompleted(HomeRecordViewController.self) { (resolver, controller) in
//            controller.recording = resolver.resolve(IRecordings.self)
//            controller.storage = resolver.resolve(IStorage.self)
//        }
//
//        container.storyboardInitCompleted(LandingViewController.self) { (resolver, controller) in
//            controller.notification = resolver.resolve(INotifications.self)
//        }
//

//
//        container.storyboardInitCompleted(PatientDirectoryViewController.self) { (resolver, controller) in
//            controller.patient = resolver.resolve(IPatient.self)
//        }
//        container.storyboardInitCompleted(DrProfileSettingsViewController.self) { (resolver, controller) in
//            controller.account = resolver.resolve(IAccount.self)
//            controller.storage = resolver.resolve(IStorage.self)
//        }
//        container.storyboardInitCompleted(TechniciansViewController.self) { (resolver, controller) in
//            controller.technicians = resolver.resolve(ITechnician.self)
//            controller.doctor = resolver.resolve(IDoctor.self)
//        }
//        container.storyboardInitCompleted(InviteDoctorViewController.self) { (resolver, controller) in
//            controller.doctor = resolver.resolve(IDoctor.self)
//        }
//        container.storyboardInitCompleted(AddInviteDrViewController.self) { (resolver, controller) in
//            controller.doctor = resolver.resolve(IDoctor.self)
//        }
//        container.storyboardInitCompleted(AddTechniciansViewController.self) { (resolver, controller) in
//            controller.technician = resolver.resolve(ITechnician.self)
//            controller.storage = resolver.resolve(IStorage.self)
//        }
//        container.storyboardInitCompleted(AddEditDoctorProfileViewController.self) { (resolver, controller) in
//            controller.account = resolver.resolve(IAccount.self)
//            controller.doctor = resolver.resolve(IDoctor.self)
//            controller.storage = resolver.resolve(IStorage.self)
//        }
//        container.storyboardInitCompleted(RecordingPreviewViewController.self) { (resolver, controller) in
//            controller.recording = resolver.resolve(IRecordings.self)
//            controller.storage = resolver.resolve(IStorage.self)
//            controller.patient = resolver.resolve(IPatient.self)
//            controller.doctor = resolver.resolve(IDoctor.self)
//            controller.account = resolver.resolve(IAccount.self)
//        }
//
//        container.storyboardInitCompleted(ForwardDoctorListViewController.self) { (resolver, controller) in
//            controller.doctor = resolver.resolve(IDoctor.self)
//            controller.recording = resolver.resolve(IRecordings.self)
//        }
//
//        container.storyboardInitCompleted(DoctorSendFeedbackViewController.self) { (resolver, controller) in
//            controller.recording = resolver.resolve(IRecordings.self)
//            controller.storage = resolver.resolve(IStorage.self)
//        }
//        container.storyboardInitCompleted(PastRecordingDetailsViewController.self) { (resolver, controller) in
//            controller.recording = resolver.resolve(IRecordings.self)
//            controller.storage = resolver.resolve(IStorage.self)
//            controller.doctor = resolver.resolve(IDoctor.self)
//            controller.account = resolver.resolve(IAccount.self)
//        }
//
//        container.storyboardInitCompleted(PastRecordingsViewController.self) { (resolver, controller) in
//            controller.patient = resolver.resolve(IPatient.self)
//        }
//
//        container.storyboardInitCompleted(PatientRecordProfileViewController.self) { (resolver, controller) in
//            controller.patient = resolver.resolve(IPatient.self)
//            controller.recording = resolver.resolve(IRecordings.self)
//        }
//
//        container.storyboardInitCompleted(AddPatientViewController.self) { (resolver, controller) in
//            controller.patient = resolver.resolve(IPatient.self)
//            controller.storage = resolver.resolve(IStorage.self)
//        }
//
//
//        container.storyboardInitCompleted(ProfileSettingsViewController.self) { (resolver, controller) in
//            controller.account = resolver.resolve(IAccount.self)
//            controller.storage = resolver.resolve(IStorage.self)
//        }
//
//        container.storyboardInitCompleted(PatientSearchViewController.self) { (resolver, controller) in
//            controller.patient = resolver.resolve(IPatient.self)
//        }
//        container.storyboardInitCompleted(PreRecordingConnectionViewController.self) { (resolver, controller) in
//            controller.recording = resolver.resolve(IRecordings.self)
//        }
//

//
//        container.storyboardInitCompleted(PatientVerifyViewController.self) { (resolver, controller) in
//            controller.patient = resolver.resolve(IPatient.self)
//        }
//
//        container.storyboardInitCompleted(RecordingContinueousViewController.self) { (resolver, controller) in
//            controller.recording = resolver.resolve(IRecordings.self)
//        }
//
//        container.storyboardInitCompleted(NotificationViewController.self) { (resolver, controller) in
//            controller.notifications = resolver.resolve(INotifications.self)
//            controller.recording = resolver.resolve(IRecordings.self)
//            controller.storage = resolver.resolve(IStorage.self)
//        }
//        container.storyboardInitCompleted(OrgLoginViewController.self) { (resolver, controller) in
//            controller.organisation = resolver.resolve(IOrganisation.self)
//        }
//        container.storyboardInitCompleted(ForgotOrgIdViewController.self) { (resolver, controller) in
//            controller.organisation = resolver.resolve(IOrganisation.self)
//        }
//        container.storyboardInitCompleted(NewRegistrationOrgViewController.self) { (resolver, controller) in
//            controller.org = resolver.resolve(IOrganisation.self)
//        }
//        container.storyboardInitCompleted(DeviceNumberViewController.self) { (resolver, controller) in
//            controller.organisation = resolver.resolve(IOrganisation.self)
//        }
        
        return container
    }
}
