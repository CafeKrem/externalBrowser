Class {
	#name : #SpChooseMethodUIImproved,
	#superclass : #SpPresenter,
	#instVars : [
		'packageList',
		'classList',
		'methodList',
		'radioButtonInstanceSide',
		'radioButtonClassSide',
		'protocolList'
	],
	#category : #'Migration-Tool-ExternalBrowser'
}

{ #category : #specs }
SpChooseMethodUIImproved class >> defaultSpec [
	^ SpPanedLayout newHorizontal
		position: 33 percent;
		add: #packageList;
		add:
			(SpPanedLayout newHorizontal
				position: 50 percent;
				add: #classList;
				add:
					(SpBoxLayout newVertical
						add: #methodList;
						add:
							(SpBoxLayout newHorizontal
								add: #radioButtonInstanceSide;
								add: #radioButtonClassSide;
								yourself)
							withConstraints: [ :contraint | contraint height: 20 ];
						yourself);
				yourself);
		yourself
]

{ #category : #examples }
SpChooseMethodUIImproved class >> exampleMethodChooser [
	<example>
	(self openOnAccept: [ :chooseMethodPresenter | chooseMethodPresenter selectedMethod browse ]) withWindowDo: [ :w | w title: 'Select a method example' ]
]

{ #category : #examples }
SpChooseMethodUIImproved class >> exampleNavigationSystem [
	<example>
	| presenter |
	presenter := self new.
	(presenter openWithSpecLayout: self externalBrowserlayout)
		extent: 900 @ 400.
	^ presenter
]

{ #category : #'as yet unclassified' }
SpChooseMethodUIImproved class >> externalBrowserlayout [
	^ SpPanedLayout newHorizontal
		position: 25 percent;
		add: #packageList;
		add:
			(SpPanedLayout newHorizontal
				position: 25 percent;
				add: #classList;
				add:
					(SpPanedLayout newHorizontal
						position: 40 percent;
						add: #protocolList;
						add:
							(SpBoxLayout newVertical
								add: #methodList;
								add:
									(SpBoxLayout newHorizontal
										add: #radioButtonInstanceSide;
										add: #radioButtonClassSide;
										yourself)
									withConstraints: [ :contraint | contraint height: 20 ];
								yourself);
						yourself);
				yourself);
		yourself
]

{ #category : #'instance creation' }
SpChooseMethodUIImproved class >> openOnAccept: aBlock [
	| instance |
	instance := self new.
	instance openModalWithSpec.
	instance withWindowDo: [ :w | w okAction: [ :dialog | aBlock cull: instance cull: dialog ] ].
	^ instance
]

{ #category : #accessing }
SpChooseMethodUIImproved >> classList [
	^ classList
]

{ #category : #'initialization - actions' }
SpChooseMethodUIImproved >> classListAction [
	classList
		transmitTo: methodList
		transform: [ :selectedClass | 
			selectedClass
				ifNotNil: [ self methodsToDisplayOf: selectedClass ]
				ifNil: [ #() ] ]
		postTransmission: [ :destination | destination selectIndex: 1 ].

	classList
		transmitTo: protocolList
		transform: [ :selectedClass |
			selectedClass
				ifNotNil: [ self isInstanceButtonSelected
						ifTrue:
							[ selectedClass organization allProtocols as: OrderedCollection ]
						ifFalse:
							[ selectedClass class organization allProtocols as: OrderedCollection ] ] 
					ifNil: [ #()]]
		postTransmission: [ :protcolList | 
			protocolList
				selectIndex: ((protcolList items collect: #name) indexOf: '-- all --') ]
]

{ #category : #utilities }
SpChooseMethodUIImproved >> classMethodsOf: aClass [
	^ aClass class methods
]

{ #category : #utilities }
SpChooseMethodUIImproved >> getMethodFromAMethodSelector: methodSelector [
	^ self isInstanceButtonSelected
		ifTrue: [ classList selection selectedItem methodNamed: methodSelector ]
		ifFalse: [ classList selection selectedItem class methodNamed: methodSelector ]
]

{ #category : #initialization }
SpChooseMethodUIImproved >> initializeDialogWindow: aDialog [
	super initializeDialogWindow: aDialog.
	aDialog
		initialExtent: 600 @ 400;
		title: 'Select a method';
		closeOnBackdropClick: false
]

{ #category : #initialization }
SpChooseMethodUIImproved >> initializePresenter [
	self packageListAction.
	self classListAction.
	self protocolListAction.
	self radioButtonsAction.
	packageList selectIndex: 1
]

{ #category : #initialization }
SpChooseMethodUIImproved >> initializeWidgets [
	packageList := self newList.
	classList := self newList.
	methodList := self newList.
	radioButtonClassSide := self newRadioButton.
	radioButtonInstanceSide := self newRadioButton.
	protocolList := self newList.

	packageList
		items: RPackageOrganizer default packages;
		displayBlock: #name;
		sortingBlock: #name ascending;
		icons: [ :item | self iconNamed: #package ].

	classList
		sortingBlock: #name ascending;
		icons: [ :item | self iconNamed: item systemIconName ].

	protocolList 
		displayBlock: [:protocol |protocol name  ];
		sortingBlock: #name ascending.

	methodList
		sortingBlock: #name ascending;
		displayBlock: #selector.

	radioButtonClassSide label: 'class side'.
	radioButtonInstanceSide
		label: 'instance side';
		state: true.

	radioButtonInstanceSide associatedRadioButtons: {radioButtonClassSide}.

	self focusOrder
		add: packageList;
		add: classList;
		add: methodList
]

{ #category : #utilities }
SpChooseMethodUIImproved >> instanceMethodsOf: aClass [
	^ aClass methods
]

{ #category : #testing }
SpChooseMethodUIImproved >> isInstanceButtonSelected [
	^ radioButtonInstanceSide state
]

{ #category : #accessing }
SpChooseMethodUIImproved >> methodList [
	^ methodList
]

{ #category : #utilities }
SpChooseMethodUIImproved >> methodsToDisplayOf: aClass [
	^ (self isInstanceButtonSelected
		ifTrue: [ self instanceMethodsOf: aClass ]
		ifFalse: [ self classMethodsOf: aClass ]) asOrderedCollection
]

{ #category : #accessing }
SpChooseMethodUIImproved >> packageList [
	^ packageList
]

{ #category : #'initialization - actions' }
SpChooseMethodUIImproved >> packageListAction [
	packageList
		transmitTo: classList
		transform: [ :selectedPacakge | 
			selectedPacakge
				ifNotNil: [ selectedPacakge classes asOrderedCollection ] ]
		postTransmission: [ classList selectIndex: 1 ]
]

{ #category : #accessing }
SpChooseMethodUIImproved >> protocolList [
	^ protocolList
]

{ #category : #'initialization - actions' }
SpChooseMethodUIImproved >> protocolListAction [
	protocolList
		transmitTo: methodList
		transform: [ :selectedProtocol | 
			selectedProtocol
				ifNotNil: [ (selectedProtocol methods
						collect:
							[ :methodSelector | self getMethodFromAMethodSelector: methodSelector ])
						asOrderedCollection ]
				ifNil: [ #() asOrderedCollection ] ]
		postTransmission: [ :methodPresenter | methodPresenter selectIndex: 1 ]
]

{ #category : #accessing }
SpChooseMethodUIImproved >> radioButtonClassSide [
	^ radioButtonClassSide
]

{ #category : #accessing }
SpChooseMethodUIImproved >> radioButtonInstanceSide [
	^ radioButtonInstanceSide
]

{ #category : #'initialization - actions' }
SpChooseMethodUIImproved >> radioButtonsAction [
	radioButtonClassSide
		whenActivatedDo: [ methodList items: (self classMethodsOf: self selectedClass).
			protocolList
				items:
					(self selectedClass class protocols
						collect: [ :eachSymbol | 
							self selectedClass class organization protocolOrganizer
								protocolNamed: eachSymbol ]) ].
	radioButtonInstanceSide
		whenActivatedDo: [ methodList items: (self instanceMethodsOf: self selectedClass).
			protocolList
				items:
					(self selectedClass protocols
						collect: [ :eachSymbol | 
							self selectedClass organization protocolOrganizer
								protocolNamed: eachSymbol ]) ]
]

{ #category : #accessing }
SpChooseMethodUIImproved >> selectedClass [
	^ classList selection selectedItem
]

{ #category : #accessing }
SpChooseMethodUIImproved >> selectedMethod [
	^ methodList selectedItem
]

{ #category : #accessing }
SpChooseMethodUIImproved >> selectedPackage [
	^ packageList selectedItem
]
