//
//  GuessNumberGameViewModel.swift
//  GuessTheNumber
//
//  Created by Alexander on 13.09.24.
//
import SwiftUI

struct GuessNumberGameViewModel: Identifiable {
    let id = UUID()
   
    
    //Actions
    var onWatchCompletion: (()->())?
    var onCopyCompletion: (()->())?
    var onEditCompletion: (()->())?
    var onCancelCompletion: (()->())?
    
    init(event: Event, status: EventState) {
        self.event = event
        self.status = status
        
        switch status {
        case .active:
            actions = event.isOwner != true ? [.init(name: "Просмотреть", systemImageName: "eye", onSelection: onWatchCompletion), .init(name: "Копировать", systemImageName: "doc.on.doc", onSelection: onCopyCompletion)] : [.init(name: "Просмотреть", systemImageName: "eye", onSelection: onWatchCompletion), .init(name: "Копировать", systemImageName: "doc.on.doc", onSelection: onCopyCompletion), .init(name: "Редактировать", systemImageName: "pencil", onSelection: onEditCompletion), .init(name: "Отменить", systemImageName: "trash", onSelection: onCancelCompletion)]
        default:
            actions = [.init(name: "Просмотреть", systemImageName: "eye", onSelection: onWatchCompletion), .init(name: "Копировать", systemImageName: "doc.on.doc", onSelection: onCopyCompletion)]
        }
    }
    
    init(event: Event,
         status: EventState,
         onWatchCompletion: (()->())?,
         onCancelCompletion: (()->())?,
         onCopy: (()->())?,
         onEdit: (()->())?) {
        self.event = event
        self.status = status
        self.onWatchCompletion = onWatchCompletion
        self.onCancelCompletion = onCancelCompletion
        self.onCopyCompletion = onCopy
        self.onEditCompletion = onEdit
        
        switch status {
        case .active:
            actions = event.isOwner != true ? [.init(name: "Просмотреть", systemImageName: "eye", onSelection: onWatchCompletion), .init(name: "Копировать", systemImageName: "doc.on.doc", onSelection: onCopyCompletion)] : [.init(name: "Просмотреть", systemImageName: "eye", onSelection: onWatchCompletion), .init(name: "Копировать", systemImageName: "doc.on.doc", onSelection: onCopyCompletion), .init(name: "Редактировать", systemImageName: "pencil", onSelection: onEditCompletion), .init(name: "Отменить", systemImageName: "trash", onSelection: onCancelCompletion)]
        default:
            actions = [.init(name: "Просмотреть", systemImageName: "eye", onSelection: onWatchCompletion), .init(name: "Копировать", systemImageName: "doc.on.doc", onSelection: onCopyCompletion)]
        }
    }
    
    func getFieldsModel() -> EventBookingFieldsModel {
        let selectedDate = event.date ?? FilterService.sharedInstance.selectedDay
        let timeFrom = event.timeFrom?.toDate("HH:mm") ?? FilterService.sharedInstance.selectedTimeRange.0.toDate()
        let timeTo = event.timeTo?.toDate("HH:mm") ?? FilterService.sharedInstance.selectedTimeRange.1.toDate()

        return EventBookingFieldsModel(timeFrom: timeFrom, timeTo: timeTo, selectedDate: selectedDate, name: event.name ?? "", content: event.comment ?? "", link: event.link ?? "", files: event.files ?? [], isUser: event.isOwner ?? false, participants: event.invitedPersons?.compactMap({ $0.invitedPerson }) ?? [], eventId: self.event.id, clientID: event.clientID, personID: event.personID, placeID: event.placeID)
    }
}

final class MyEventsViewModel : ObservableObject {
    weak var rootVc: UINavigationController?

    private let filterService: PlacesFilterService = PlacesFilterService.sharedInstance
    
    @Published var selectionIndex: Int = 1
    
    @Published var allEvents: [EventViewModel] = []
    @Published var activeEvents: [EventViewModel] = []
    @Published var completedEvents: [EventViewModel] = []
    @Published var canceledEvents: [EventViewModel] = []
    @Published var selectedType = EventPersonType.all.rawValue
    @Published var isLoading = false
    
    private var result: [Event] = []
    private var currentRequest: ()?
    
    var filterActive: Bool {
        return selectedType != EventPersonType.all.rawValue
    }
    
    // MARK: - Requests
    func fetchMyEvents() {
        guard currentRequest == nil else { return }
        isLoading = true
        currentRequest = GetEventsAction().execute { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.currentRequest = nil
                NotificationCenter.default.post(name: NSNotification.Name.fetchBookingsAndUpdate, object: nil)
            }
    
            switch result {
            case .success(let model):
                DispatchQueue.main.async {
                    self?.prepareEventViewModels(model)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showCoomonFailurePopup(title: error.localizedDescription)
                }
            }
        }
    }
    
    func deleteEventPressed(_ event: EventViewModel) {
        rootVc?.showDeleteAlert(title: "Вы уверены?", description: "Мероприятие \(event.event.name ?? "") будет отменено", onAccept: { [weak self] in
            self?.deleteEvent(event)
        })
    }
    
    func deleteEvent(_ event: EventViewModel) {
        guard let eventId = event.event.id, currentRequest == nil else { return }
        isLoading = true
        currentRequest = DeleteBookingAction().execute(model: DeleteBookingAction.RequestModel(id: eventId)) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.currentRequest = nil
            }
            
            switch result {
            case .success(let model):
                let errorCode = model.errorCode
                DispatchQueue.main.async {
                    switch errorCode {
                    case 0:
                        self?.fetchMyEvents()
                    default:
                        self?.showCoomonFailurePopup(title: model.errorDescription ?? "Произошла техническая ошибка")
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showCoomonFailurePopup(title: error.localizedDescription)
                }
            }
        }
    }
    
    private func prepareEventViewModels(_ result: [Event]) {
        self.result = result
        applyFilter()
    }
    
    func applyFilter() {
        allEvents.removeAll()
        activeEvents.removeAll()
        completedEvents.removeAll()
        canceledEvents.removeAll()
        
        result.sortedByTime().forEach { event in
            guard let type = EventPersonType(rawValue: selectedType) else { return }
            
            if type == .owner, event.isOwner == false {
                return
            }
            
            if type == .contributor, event.isOwner == true {
                return
            }
            
            var selectedEventState: EventState = .active
            
            let onPreview: (()->()) = { [weak self] in
                self?.showEventPreview(EventViewModel(event: event, status: selectedEventState))
            }
            
            let onDelete: (()->()) = { [weak self] in
                self?.deleteEventPressed(EventViewModel(event: event, status: selectedEventState))
            }
            
            let onCopy: (()->()) = { [weak self] in
                self?.showEventAction(EventViewModel(event: event, status: selectedEventState), operationType: .booking)
            }
            
            let onEdit: (()->()) = { [weak self] in
                self?.showEventAction(EventViewModel(event: event, status: selectedEventState), operationType: .editing)
            }
            
            guard event.isCanceled != 1 else {
                selectedEventState = .canceled
                canceledEvents.append(EventViewModel(event: event, status: .canceled, onWatchCompletion: onPreview, onCancelCompletion: onDelete, onCopy: onCopy, onEdit: onEdit))
                allEvents.append(EventViewModel(event: event, status: .canceled, onWatchCompletion: onPreview, onCancelCompletion: onDelete, onCopy: onCopy, onEdit: onEdit))
                return
            }
            
            if let date = event.date {
                if date.startOfDay() == Date().startOfDay(),
                    let startTime = event.timeFrom?.toDate("HH:mm"), let endTime = event.timeTo?.toDate("HH:mm"),
                   ((startTime...endTime).contains(Date().getCurrentTimeHoursMinutes().toDate()) || startTime > Date().getCurrentTimeHoursMinutes().toDate()) {
                    selectedEventState = .active
                    activeEvents.append(EventViewModel(event: event, status: .active, onWatchCompletion: onPreview, onCancelCompletion: onDelete, onCopy: onCopy, onEdit: onEdit))
                    allEvents.append(EventViewModel(event: event, status: .active, onWatchCompletion: onPreview, onCancelCompletion: onDelete, onCopy: onCopy, onEdit: onEdit))
                } else if date.startOfDay() > Date().startOfDay() {
                    selectedEventState = .active
                    activeEvents.append(EventViewModel(event: event, status: .active, onWatchCompletion: onPreview, onCancelCompletion: onDelete, onCopy: onCopy, onEdit: onEdit))
                    allEvents.append(EventViewModel(event: event, status: .active, onWatchCompletion: onPreview, onCancelCompletion: onDelete, onCopy: onCopy, onEdit: onEdit))
                } else {
                    selectedEventState = .completed
                    completedEvents.append(EventViewModel(event: event, status: .completed, onWatchCompletion: onPreview, onCancelCompletion: onDelete, onCopy: onCopy, onEdit: onEdit))
                    allEvents.append(EventViewModel(event: event, status: .completed, onWatchCompletion: onPreview, onCancelCompletion: onDelete, onCopy: onCopy, onEdit: onEdit))
                }
            } else {
                selectedEventState = .completed
                completedEvents.append(EventViewModel(event: event, status: .completed, onWatchCompletion: onPreview, onCancelCompletion: onDelete, onCopy: onCopy, onEdit: onEdit))
                allEvents.append(EventViewModel(event: event, status: .completed, onWatchCompletion: onPreview, onCancelCompletion: onDelete, onCopy: onCopy, onEdit: onEdit))
            }
        }
        sortByAscendingTime()
    }
    
    private func sortByAscendingTime() {
        activeEvents = activeEvents.sorted { (firsItem, secondItem) in
            if (firsItem.event.date ?? Date()) < (secondItem.event.date ?? Date()) {
                return true
            } else {
                if (firsItem.event.date ?? Date()) == (secondItem.event.date ?? Date()) {
                    return (firsItem.event.timeFrom ?? "" < secondItem.event.timeFrom ?? "")
                }
                return false
            }
        }
    }
    
    func showEventPreview(_ event: EventViewModel) {
        let viewModel = EventPreviewViewModel(event: event)
        viewModel.rootVc = rootVc
        let screen = EventPreviewScreen(viewModel: viewModel)
        let hostVC = UIHostingController(rootView: screen)
        hostVC.navigationItem.title = event.event.name ?? "Просмотр бронирования"
        hostVC.hidesBottomBarWhenPushed = true
        rootVc?.pushViewController(hostVC, animated: true)
    }
    
    func showEventAction(_ event: EventViewModel, operationType: BookingEditStyle) {
        var type: PlaceTypeId {
            guard let place = filterService.allPlaces.first(where: { $0.id == event.event.placeID }) else { return PlaceTypeId.workplace }
            return place.place_type_id ?? .workplace
        }
        
        guard let place = filterService.allPlaces.first(where: { $0.id == event.event.placeID }) else { return }
        
        if type == .workplace {
            showWorkplaceBookingScreen(place, event: event, operationType: operationType)
        } else {
            showMeetingRoomBookingScreen(place, event: event, operationType: operationType)
        }
    }
    
    func showWorkplaceBookingScreen(_ place: Place, event: EventViewModel, operationType: BookingEditStyle) {
        let viewModel = WorkplaceBookingViewModel(place: place, event: event.getFieldsModel(), operationStyle: operationType)
        viewModel.operationStyle = operationType
        viewModel.rootVc = rootVc
        let screen = WorkplaceBookingScreen(viewModel: viewModel)
        let hostVC = UIHostingController(rootView: screen)
        hostVC.navigationItem.title = "Бронирование рабочего места"
        hostVC.hidesBottomBarWhenPushed = true
        rootVc?.pushViewController(hostVC, animated: true)
    }
    
    func showMeetingRoomBookingScreen(_ place: Place, event: EventViewModel, operationType: BookingEditStyle) {
        let viewModel = MeetingRoomBookingViewModel(place: place, event: event.getFieldsModel())
        viewModel.operationStyle = operationType
        viewModel.rootVc = rootVc
        let screen = MeetingRoomBookingScreen(viewModel: viewModel)
        let hostVC = UIHostingController(rootView: screen)
        hostVC.navigationItem.title = "Бронирование переговорки"
        hostVC.hidesBottomBarWhenPushed = true
        rootVc?.pushViewController(hostVC, animated: true)
    }
    
    private func showCoomonFailurePopup(title: String) {
        rootVc?.showPopupError(title)
    }
}

