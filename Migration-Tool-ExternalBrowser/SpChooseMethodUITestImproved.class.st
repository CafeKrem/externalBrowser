Class {
	#name : #SpChooseMethodUITestImproved,
	#superclass : #TestCase,
	#instVars : [
		'biChooseMethod'
	],
	#category : #'Migration-Tool-ExternalBrowser'
}

{ #category : #running }
SpChooseMethodUITestImproved >> setUp [
	super setUp.
	biChooseMethod := SpChooseMethodUIImproved new
]

{ #category : #tests }
SpChooseMethodUITestImproved >> testClassSideRadioButtonState [
	biChooseMethod radioButtonClassSide click.
	self deny: biChooseMethod isInstanceButtonSelected
]

{ #category : #tests }
SpChooseMethodUITestImproved >> testClickOnClassSideRadioButtonShouldFillTheMethodList [
	biChooseMethod packageList selectItem: SpMethodChooserMockClass package.
	biChooseMethod classList selectItem: SpMethodChooserMockClass.
	biChooseMethod radioButtonClassSide click.
	self assertCollection: biChooseMethod methodList items hasSameElements: SpMethodChooserMockClass class methods
]

{ #category : #tests }
SpChooseMethodUITestImproved >> testInitializeClassListShouldBeSelectTheFistItem [
	self assert: biChooseMethod classList selection selectedIndex equals: 1
]

{ #category : #tests }
SpChooseMethodUITestImproved >> testInitializeIsInstanceButtonSelectedShouldBetrue [
	self assert: biChooseMethod isInstanceButtonSelected
]

{ #category : #tests }
SpChooseMethodUITestImproved >> testInitializeMethodListShouldBeSelectTheFistItem [
	self assert: biChooseMethod methodList selection selectedIndex equals: 1
]

{ #category : #tests }
SpChooseMethodUITestImproved >> testInitializePackageListShouldBeSelectTheFistItem [
	self assert: biChooseMethod packageList selection selectedIndex equals: 1
]

{ #category : #tests }
SpChooseMethodUITestImproved >> testInitializeProtocolListShouldSelectedItemSetToAll [
	self
		assert: biChooseMethod protocolList selection selectedItem name
		equals: '-- all --'
]

{ #category : #tests }
SpChooseMethodUITestImproved >> testInstanceSideRadioButtonClickIsInstanceButtonShouldbeTrue [
	biChooseMethod radioButtonClassSide click.
	self deny: biChooseMethod isInstanceButtonSelected.
	biChooseMethod radioButtonInstanceSide click.
	self assert: biChooseMethod isInstanceButtonSelected
]

{ #category : #tests }
SpChooseMethodUITestImproved >> testMethodListContentWhenClassSideIsSelected [
	biChooseMethod radioButtonClassSide click.
	biChooseMethod packageList selectItem: SpMethodChooserMockClass package.
	biChooseMethod classList selectItem: SpMethodChooserMockClass.

	self denyEmpty: biChooseMethod methodList items.
	self assert: biChooseMethod methodList selection selectedIndex equals: 1.
	self assertCollection: SpMethodChooserMockClass class methods hasSameElements: biChooseMethod methodList items
]

{ #category : #tests }
SpChooseMethodUITestImproved >> testMethodListContentWhenInstanceSideIsSelected [
	biChooseMethod radioButtonInstanceSide click.
	biChooseMethod packageList selectItem: SpMethodChooserMockClass package.
	biChooseMethod classList selectItem: SpMethodChooserMockClass.

	self denyEmpty: biChooseMethod methodList items.
	self assert: biChooseMethod methodList selection selectedIndex equals: 1.
	self assertCollection: SpMethodChooserMockClass methods hasSameElements: biChooseMethod methodList items
]

{ #category : #tests }
SpChooseMethodUITestImproved >> testSelectAClassShouldDisplayHisProtcolInProtocolList [
	biChooseMethod packageList
		selectIndex:
			((biChooseMethod packageList items collect: #name)
				indexOf: 'Spec2-PolyWidgets-Tests').
	biChooseMethod classList
		selectIndex:
			((biChooseMethod classList items collect: #name)
				indexOf: 'SpMethodChooserMockClass').
	self
		assertCollection: (biChooseMethod protocolList items collect: #name)
		hasSameElements: #(#'-- all --' #accessing)
]

{ #category : #tests }
SpChooseMethodUITestImproved >> testTransmissionFromPackageToClassList [
	| package |
	package := RPackage named: 'MigratePrettyPrinterUI-Tests-environementEmpty' asSymbol.
	biChooseMethod packageList items: {package}.
	biChooseMethod packageList selectItem: package.
	self assertEmpty: biChooseMethod classList items.
	self assert: biChooseMethod classList selection selectedItem isNil
]

{ #category : #tests }
SpChooseMethodUITestImproved >> testWhenSelectAProtocolShouldMethodListOnlyContainsMethodWithSelectedProtocol [
	biChooseMethod packageList
		selectIndex:
			((biChooseMethod packageList items collect: #name)
				indexOf: 'Migration-Tool-ExternalBrowser').
	biChooseMethod classList
		selectIndex:
			((biChooseMethod classList items collect: #name)
				indexOf: self class name).
	biChooseMethod protocolList
		selectIndex:
			((biChooseMethod protocolList items collect: #name) indexOf: 'running').
	self
		assert:
			(biChooseMethod methodList items
				allSatisfy: [ :method | method category = 'running' ])
]
