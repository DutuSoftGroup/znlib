{*******************************************************************************
  ����: dmzn@163.com 2008-8-11
  ����: �ؼ���DevExpress������Ԫ

  ��ע:
  &.��д����ʱ,������ԪUses����Ŀ�м���.
*******************************************************************************}
unit UcxChinese;

{$I cxVer.inc}
interface

uses
  cxClasses, cxGridStrs, cxExportStrs, cxLibraryStrs, cxGridPopupMenuConsts,
  dxExtCtrlsStrs, dxPSRes, cxFilterConsts, cxDataConsts, cxFilterControlStrs,
  cxEditConsts, dxBarStrs, dxNavBarConsts;

implementation

procedure ApplyChineseResourceString;
begin
  //cxExportStrs.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@scxUnsupportedExport, '���ṩ���������: %1');
  //'Unsupported export type: %1');
  cxSetResourceString(@scxStyleManagerKill, '��ʽ���������ڱ�ʹ�û����ͷ�');
  //'The Style Manager is currently being used elsewhere and can not be released at this stage');
  cxSetResourceString(@scxStyleManagerCreate, '���ܴ�����ʽ������');
  //'Can''t create style manager');

  cxSetResourceString(@scxExportToHtml, '�������ҳ (*.html)');
  //'Export to Web page (*.html)');
  cxSetResourceString(@scxExportToXml, '�����XML�ĵ� (*.xml)');
  //'Export to XML document (*.xml)');
  cxSetResourceString(@scxExportToText, '������ı��ļ� (*.txt)');
  //'Export to text format (*.txt)');

  cxSetResourceString(@scxEmptyExportCache, '�������Ϊ��');
  //'Export cache is empty');
  cxSetResourceString(@scxIncorrectUnion, '����ȷ�ĵ�Ԫ���');
  //'Incorrect union of cells');
  cxSetResourceString(@scxIllegalWidth, '�Ƿ����п�');
  //'Illegal width of the column');
  cxSetResourceString(@scxInvalidColumnRowCount, '��Ч������������');
  //'Invalid column or row count');
  cxSetResourceString(@scxIllegalHeight, '�Ƿ����и�');
  //'Illegal height of the row');
  cxSetResourceString(@scxInvalidColumnIndex, '�б� %d ������Χ');
  //'The column index %d out of bounds');
  cxSetResourceString(@scxInvalidRowIndex, '�к� %d ������Χ');
  //'The row index %d out of bounds');
  cxSetResourceString(@scxInvalidStyleIndex, '��Ч����ʽ���� %d');
  //'Invalid style index %d');

  cxSetResourceString(@scxExportToExcel, '����� MS Excel�ļ� (*.xls)');
  //'Export to MS Excel (*.xls)');
  cxSetResourceString(@scxWorkbookWrite, 'д XLS �ļ�����');
  cxSetResourceString(@scxInvalidCellDimension, '��Ч�ĵ�Ԫά��');
  //'Invalid cell dimension');
  cxSetResourceString(@scxBoolTrue, '��');
  //'True');
  cxSetResourceString(@scxBoolFalse, '��');
  //'False';

  //cxLibraryStrs.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@scxCantCreateRegistryKey, '���ܴ���ע����ֵ: \%s');
  //'Can''t create the registry key: \%s');
  cxSetResourceString(@scxCantOpenRegistryKey, '���ܴ�ע����ֵ: \%s');
  //'Can''t open the registry key: \%s';
  cxSetResourceString(@scxErrorStoreObject, '���� %s �������');
  //'Error store %s object';

  {$IFNDEF DELPHI5}
  cxSetResourceString(@scxInvalidPropertyElement, '��Ч������Ԫ��: %s');
  //'Invalid property element: %s');
  {$ENDIF}
  cxSetResourceString(@scxConverterCantCreateStyleRepository, '���ܴ���Style Repository');
  //'Can''t create the Style Repository');

  cxSetResourceString(@cxSDateToday, '����');
  //'today'
  cxSetResourceString(@cxSDateYesterday, '����');
  //'yesterday'
  cxSetResourceString(@cxSDateTomorrow, '����');
  //tomorrow
  cxSetResourceString(@cxSDateSunday, '������');
  //Sunday
  cxSetResourceString(@cxSDateMonday, '����һ');
  //Monday
  cxSetResourceString(@cxSDateTuesday, '���ڶ�');
  //Tuesday
  cxSetResourceString(@cxSDateWednesday, '������');
  //Wednesday
  cxSetResourceString(@cxSDateThursday, '������');
  //Thursday
  cxSetResourceString(@cxSDateFriday, '������');
  //Friday
  cxSetResourceString(@cxSDateSaturday, '������');
  //Saturday
  cxSetResourceString(@cxSDateFirst, '��һ��');
  //first
  cxSetResourceString(@cxSDateSecond, '�ڶ���');
  //second
  cxSetResourceString(@cxSDateThird, '������');
  //third
  cxSetResourceString(@cxSDateFourth, '������');
  //fourth
  cxSetResourceString(@cxSDateFifth, '������');
  //fifth
  cxSetResourceString(@cxSDateSixth, '������');
  //sixth
  cxSetResourceString(@cxSDateSeventh, '������');
  //seventh
  cxSetResourceString(@cxSDateBOM, 'bom');
  cxSetResourceString(@cxSDateEOM, 'eom');
  cxSetResourceString(@cxSDateNow, '��ǰ');
  //Now

  //cxGridStrs.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@scxGridRecursiveLevels, '�����ܴ����ݹ��');
  //'You cannot create recursive levels');

  cxSetResourceString(@scxGridDeletingConfirmationCaption, '��ʾ');
  //'Confirm');
  cxSetResourceString(@scxGridDeletingFocusedConfirmationText, 'ɾ��������?');
  //'Delete record?');
  cxSetResourceString(@scxGridDeletingSelectedConfirmationText, 'ɾ������ѡ���ļ�¼��?');

  cxSetResourceString(@scxGridNoDataInfoText, '<û���κμ�¼>');

  cxSetResourceString(@scxGridNewItemRowInfoText, '�����˴����һ����');
  //'Click here to add a new row');

  cxSetResourceString(@scxGridFilterIsEmpty, '<���ݹ�������Ϊ��>');
  //'<Filter is Empty>');

  cxSetResourceString(@scxGridCustomizationFormCaption, '����');
  //'Customization');
  cxSetResourceString(@scxGridCustomizationFormColumnsPageCaption, '��');
  cxSetResourceString(@scxGridGroupByBoxCaption, '���б����Ϸŵ��˴�ʹ��¼�����н��з���');
  //'Drag a column header here to group by that column');
  cxSetResourceString(@scxGridFilterCustomizeButtonCaption, '����...');
  //'Customize...');
  cxSetResourceString(@scxGridColumnsQuickCustomizationHint, '���ѡ�������');
  // 'Click here to select visible columns');

  cxSetResourceString(@scxGridCustomizationFormBandsPageCaption, '����');
  // 'Bands');
  cxSetResourceString(@scxGridBandsQuickCustomizationHint, '���ѡ���������');
  //'Click here to select visible bands');

  cxSetResourceString(@scxGridCustomizationFormRowsPageCaption, '��'); // 'Rows');

  cxSetResourceString(@scxGridConverterIntermediaryMissing, 'ȱ��һ���м����!'#13#10'�����һ�� %s ���������.');
  //'Missing an intermediary component!'#13#10'Please add a %s component to the form.');
  cxSetResourceString(@scxGridConverterNotExistGrid, 'cxGrid ������');
  //'cxGrid does not exist');
  cxSetResourceString(@scxGridConverterNotExistComponent, '���������');
  //'Component does not exist');
  cxSetResourceString(@scxImportErrorCaption, '�������');
  //'Import error');

  cxSetResourceString(@scxNotExistGridView, 'Grid ��ͼ������');
  //'Grid view does not exist');
  cxSetResourceString(@scxNotExistGridLevel, '��� grid �㲻����');
  //'Active grid level does not exist');
  cxSetResourceString(@scxCantCreateExportOutputFile, '���ܽ��������ļ�');
  //'Can''t create the export output file');

  cxSetResourceString(@cxSEditRepositoryExtLookupComboBoxItem,
    'ExtLookupComboBox|Represents an ultra-advanced lookup using the QuantumGrid as its drop down control');

  cxSetResourceString(@scxGridChartValueHintFormat, '%s for %s is %s');
  // series display text, category, value     

  //cxGridPopupMenuConsts.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@cxSGridNone, '��');
  //'None');

  //Header popup menu captions
  cxSetResourceString(@cxSGridSortColumnAsc, '����');
  //'Sort Ascending');
  cxSetResourceString(@cxSGridSortColumnDesc, '����');
  //'Sort Descending');
  cxSetResourceString(@cxSGridClearSorting, '�������');

  //'Clear Sorting');
  cxSetResourceString(@cxSGridGroupByThisField, '���մ��ֶη���');
  //'Group By This Field');
  cxSetResourceString(@cxSGridRemoveThisGroupItem, '�Ӹ���ɾ��');
  //'Remove from grouping');
  cxSetResourceString(@cxSGridGroupByBox, '��ʾ/���ط����');
  //'Group By Box');
  cxSetResourceString(@cxSGridAlignmentSubMenu, '����');
  //'Alignment');
  cxSetResourceString(@cxSGridAlignLeft, '�����');
  //'Align Left');
  cxSetResourceString(@cxSGridAlignRight, '�Ҷ���');
  //'Align Right');
  cxSetResourceString(@cxSGridAlignCenter, '���ж���');
  //'Align Center');
  cxSetResourceString(@cxSGridRemoveColumn, 'ɾ������');
  //'Remove This Column');
  cxSetResourceString(@cxSGridFieldChooser, 'ѡ���ֶ�');
  //'Field Chooser');
  cxSetResourceString(@cxSGridBestFit, '�ʺ��п�');
  //'Best Fit');
  cxSetResourceString(@cxSGridBestFitAllColumns, '�ʺ��п� (������)');
  //'Best Fit (all columns)');
  cxSetResourceString(@cxSGridShowFooter, '��ע');
  //'Footer');
  cxSetResourceString(@cxSGridShowGroupFooter, '���ע');
  //'Group Footers');

  //Footer popup menu captions
  cxSetResourceString(@cxSGridSumMenuItem, '�ϼ�');
  //'Sum');
  cxSetResourceString(@cxSGridMinMenuItem, '��С');
  //'Min');
  cxSetResourceString(@cxSGridMaxMenuItem, '���');
  //'Max');
  cxSetResourceString(@cxSGridCountMenuItem, '����');
  //'Count');
  cxSetResourceString(@cxSGridAvgMenuItem, 'ƽ��');
  //'Average');
  cxSetResourceString(@cxSGridNoneMenuItem, '��');
  //'None');

  //dxExtCtrlsStrs.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@sdxAutoColorText, '�Զ�');
  ////'Auto');
  cxSetResourceString(@sdxCustomColorText, '����...');
  ////'Custom...');

  cxSetResourceString(@sdxSysColorScrollBar, '������');
  ////'ScrollBar');
  cxSetResourceString(@sdxSysColorBackground, '����');
  ////'Background');
  cxSetResourceString(@sdxSysColorActiveCaption, '��������');
  ////'Active Caption');
  cxSetResourceString(@sdxSysColorInactiveCaption, '�������');
  ////'Inactive Caption');
  cxSetResourceString(@sdxSysColorMenu, '�˵�');
  ////'Menu');
  cxSetResourceString(@sdxSysColorWindow, '����');
  ////'Window');
  cxSetResourceString(@sdxSysColorWindowFrame, '���ڿ��');
  ////'Window Frame');
  cxSetResourceString(@sdxSysColorMenuText, '�˵��ı�');
  ////'Menu Text');
  cxSetResourceString(@sdxSysColorWindowText, '�����ı�t');
  ////'Window Text');
  cxSetResourceString(@sdxSysColorCaptionText, '�����ı�');
  ////'Caption Text');
  cxSetResourceString(@sdxSysColorActiveBorder, '��߿�');
  ////'Active Border');
  cxSetResourceString(@sdxSysColorInactiveBorder, '����߿�');
  ////'Inactive Border');
  cxSetResourceString(@sdxSysColorAppWorkSpace, '�������ռ�');
  ////'App Workspace');
  cxSetResourceString(@sdxSysColorHighLight, '����');
  ////'Highlight');
  cxSetResourceString(@sdxSysColorHighLighText, '�����ı�');
  ////'Highlight Text');
  cxSetResourceString(@sdxSysColorBtnFace, '��ť����');
  ////'Button Face');
  cxSetResourceString(@sdxSysColorBtnShadow, '��ť��Ӱ');
  ////'Button Shadow');
  cxSetResourceString(@sdxSysColorGrayText, '��ɫ�ı�');
  ////'Gray Text');
  cxSetResourceString(@sdxSysColorBtnText, '��ť�ı�');
  ////'Button Text');
  cxSetResourceString(@sdxSysColorInactiveCaptionText, '����ı����ı�');
  ////'Inactive Caption Text');
  cxSetResourceString(@sdxSysColorBtnHighligh, '��ť����');
  ////'Button Highlight');
  cxSetResourceString(@sdxSysColor3DDkShadow, '3DDk ��Ӱ');
  ////'3DDk Shadow');
  cxSetResourceString(@sdxSysColor3DLight, '3D ����');
  ////'3DLight');
  cxSetResourceString(@sdxSysColorInfoText, '��Ϣ�ı�');
  ////'Info Text');
  cxSetResourceString(@sdxSysColorInfoBk, '��Ϣ����');
  ////'InfoBk');

  cxSetResourceString(@sdxPureColorBlack, '��');
  ////'Black');
  cxSetResourceString(@sdxPureColorRed, '��');
  ////'Red');
  cxSetResourceString(@sdxPureColorLime, '��');
  ////'Lime');
  cxSetResourceString(@sdxPureColorYellow, '��');
  ////'Yellow');
  cxSetResourceString(@sdxPureColorGreen, '��');
  ////'Green');
  cxSetResourceString(@sdxPureColorTeal, '��');
  ////'Teal');
  cxSetResourceString(@sdxPureColorAqua, 'ǳ��');
  ////'Aqua');
  cxSetResourceString(@sdxPureColorBlue, '��');
  ////'Blue');
  cxSetResourceString(@sdxPureColorWhite, '��');
  ////'White');
  cxSetResourceString(@sdxPureColorOlive, 'ǳ��');
  ////'Olive');
  cxSetResourceString(@sdxPureColorMoneyGreen, '����');
  ////'Money Green');
  cxSetResourceString(@sdxPureColorNavy, '����');
  ////'Navy');
  cxSetResourceString(@sdxPureColorSkyBlue, '����');
  ////'Sky Blue');
  cxSetResourceString(@sdxPureColorGray, '��');
  ////'Gray');
  cxSetResourceString(@sdxPureColorMedGray, '�л�');
  ////'Medium Gray');
  cxSetResourceString(@sdxPureColorSilver, '��');
  ////'Silver');
  cxSetResourceString(@sdxPureColorMaroon, '��ɫ');
  ////'Maroon');
  cxSetResourceString(@sdxPureColorPurple, '��');
  ////'Purple');
  cxSetResourceString(@sdxPureColorFuchsia, '�Ϻ�');
  ////'Fuchsia');
  cxSetResourceString(@sdxPureColorCream, '��ɫ');
  ////'Cream');

  cxSetResourceString(@sdxBrushStyleSolid, '����');
  ////'Solid');
  cxSetResourceString(@sdxBrushStyleClear, '���');
  ////'Clear');
  cxSetResourceString(@sdxBrushStyleHorizontal, 'ˮƽ');
  ////'Horizontal');
  cxSetResourceString(@sdxBrushStyleVertical, '��ֱ');
  ////'Vertical');
  cxSetResourceString(@sdxBrushStyleFDiagonal, 'Fб��');
  ////'FDiagonal');
  cxSetResourceString(@sdxBrushStyleBDiagonal, 'Bб��');
  ////'BDiagonal');
  cxSetResourceString(@sdxBrushStyleCross, '����');
  ////'Cross');
  cxSetResourceString(@sdxBrushStyleDiagCross, '������');
  ////'DiagCross');

  //cxFilterConsts.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // base operators
  cxSetResourceString(@cxSFilterOperatorEqual, '����');
  //'equals');
  cxSetResourceString(@cxSFilterOperatorNotEqual, '������');
  //'does not equal');
  cxSetResourceString(@cxSFilterOperatorLess, 'С��');
  //'is less than');
  cxSetResourceString(@cxSFilterOperatorLessEqual, 'С�ڵ���');
  //'is less than or equal to');
  cxSetResourceString(@cxSFilterOperatorGreater, '����');
  //'is greater than');
  cxSetResourceString(@cxSFilterOperatorGreaterEqual, '���ڵ���');
  //'is greater than or equal to');
  cxSetResourceString(@cxSFilterOperatorLike, '����');
  //'like');
  cxSetResourceString(@cxSFilterOperatorNotLike, '������');
  //'not like');
  cxSetResourceString(@cxSFilterOperatorBetween, '��...֮��');
  //'between');
  cxSetResourceString(@cxSFilterOperatorNotBetween, '����...֮��');
  //'not between');
  cxSetResourceString(@cxSFilterOperatorInList, '����');
  //'in');
  cxSetResourceString(@cxSFilterOperatorNotInList, '������');
  //'not in');

  cxSetResourceString(@cxSFilterOperatorYesterday, '����');
  //'is yesterday');
  cxSetResourceString(@cxSFilterOperatorToday, '����');
  //'is today');
  cxSetResourceString(@cxSFilterOperatorTomorrow, '����');
  //'is tomorrow');

  cxSetResourceString(@cxSFilterOperatorLastWeek, 'ǰһ��');
  //'is last week');
  cxSetResourceString(@cxSFilterOperatorLastMonth, 'ǰһ��');
  //'is last month');
  cxSetResourceString(@cxSFilterOperatorLastYear, 'ǰһ��');
  //'is last year');

  cxSetResourceString(@cxSFilterOperatorThisWeek, '����');
  //'is this week');
  cxSetResourceString(@cxSFilterOperatorThisMonth, '����');
  //'is this month');
  cxSetResourceString(@cxSFilterOperatorThisYear, '����');
  //'is this year');

  cxSetResourceString(@cxSFilterOperatorNextWeek, '��һ��');
  //'is next week');
  cxSetResourceString(@cxSFilterOperatorNextMonth, '��һ��');
  //'is next month');
  cxSetResourceString(@cxSFilterOperatorNextYear, '��һ��');
  //'is next year');

  cxSetResourceString(@cxSFilterAndCaption, '����');
  //'and');
  cxSetResourceString(@cxSFilterOrCaption, '����');
  //'or');
  cxSetResourceString(@cxSFilterNotCaption, '��');
  //'not');
  cxSetResourceString(@cxSFilterBlankCaption, '��');
  //'blank');

  // derived
  cxSetResourceString(@cxSFilterOperatorIsNull, 'Ϊ��');
  //'is blank');
  cxSetResourceString(@cxSFilterOperatorIsNotNull, '��Ϊ��');
  //'is not blank');
  cxSetResourceString(@cxSFilterOperatorBeginsWith, '��ʼ��');
  //'begins with');
  cxSetResourceString(@cxSFilterOperatorDoesNotBeginWith, '����ʼ��');
  //'does not begin with');
  cxSetResourceString(@cxSFilterOperatorEndsWith, '������');
  //'ends with');
  cxSetResourceString(@cxSFilterOperatorDoesNotEndWith, '��������');
  //'does not end with');
  cxSetResourceString(@cxSFilterOperatorContains, '����');
  //'contains');
  cxSetResourceString(@cxSFilterOperatorDoesNotContain, '������');
  //'does not contain');
  // filter listbox's values
  cxSetResourceString(@cxSFilterBoxAllCaption, '(ȫ����ʾ)');
  //'(All)');
  cxSetResourceString(@cxSFilterBoxCustomCaption, '(���ƹ���...)');
  //'(Custom...)');
  cxSetResourceString(@cxSFilterBoxBlanksCaption, '(Ϊ��)');
  //'(Blanks)');
  cxSetResourceString(@cxSFilterBoxNonBlanksCaption, '(��Ϊ��)');
  //'(NonBlanks)');

  //cxDataConsts.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@cxSDataReadError, '����������');
  ////'Stream read error');
  cxSetResourceString(@cxSDataWriteError, '���������');
  ////'Stream write error');
  cxSetResourceString(@cxSDataItemExistError, '��Ŀ�Ѿ�����');
  ////'Item already exists');
  cxSetResourceString(@cxSDataRecordIndexError, '��¼����������Χ');
  ////'RecordIndex out of range');
  cxSetResourceString(@cxSDataItemIndexError, '��Ŀ����������Χ');
  ////'ItemIndex out of range');
  cxSetResourceString(@cxSDataProviderModeError, '�����ṩ�߲��ṩ�ò���');
  ////'This operation is not supported in provider mode');
  cxSetResourceString(@cxSDataInvalidStreamFormat, '���������ʽ');
  ////'Invalid stream format');
  cxSetResourceString(@cxSDataRowIndexError, '������������Χ');
  ////'RowIndex out of range');
  //  cxSetResourceString(@cxSDataRelationItemExistError,'������Ŀ������');
  ////'Relation Item already exists');
  //  cxSetResourceString(@cxSDataRelationCircularReference,'ϸ�����ݿ�����ѭ������');
  ////'Circular Reference on Detail DataController');
  //  cxSetResourceString(@cxSDataRelationMultiReferenceError,'����ϸ�����ݿ������Ѿ�����');
  ////'Reference on Detail DataController already exists');
  cxSetResourceString(@cxSDataCustomDataSourceInvalidCompare, 'GetInfoForCompare û��ʵ��');
  ////'GetInfoForCompare not implemented');

  //  cxSDBDataSetNil,'���ݼ�Ϊ��');
  ////'DataSet is nil');
  cxSetResourceString(@cxSDBDetailFilterControllerNotFound, 'ϸ�����ݿ�����û�з���');
  ////'DetailFilterController not found');
  cxSetResourceString(@cxSDBNotInGridMode, '���ݿ��������ڱ��(Grid)ģʽe');
  ////'DataController not in GridMode');
  cxSetResourceString(@cxSDBKeyFieldNotFound, 'Key Field not found');

  //cxFilterControlStrs.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // cxFilterBoolOperator
  cxSetResourceString(@cxSFilterBoolOperatorAnd, '����'); // all
  //'AND');        // all
  cxSetResourceString(@cxSFilterBoolOperatorOr, '����'); // any
  //'OR');          // any
  cxSetResourceString(@cxSFilterBoolOperatorNotAnd, '�ǲ���'); // not all
  //'NOT AND'); // not all
  cxSetResourceString(@cxSFilterBoolOperatorNotOr, '�ǻ���'); // not any
  //'NOT OR');   // not any
  //
  cxSetResourceString(@cxSFilterRootButtonCaption, '����');
  //'Filter');
  cxSetResourceString(@cxSFilterAddCondition, '�������(&C)');
  //'Add &Condition');
  cxSetResourceString(@cxSFilterAddGroup, '�����(&G)');
  //'Add &Group');
  cxSetResourceString(@cxSFilterRemoveRow, 'ɾ����(&R)');
  //'&Remove Row');
  cxSetResourceString(@cxSFilterClearAll, '���(&A)');
  //'Clear &All');
  cxSetResourceString(@cxSFilterFooterAddCondition, '���˰�ť����������');
  //'press the button to add a new condition');

  cxSetResourceString(@cxSFilterGroupCaption, 'ʹ�����������');

  //'applies to the following conditions');
  cxSetResourceString(@cxSFilterRootGroupCaption, '<��>');
  //'<root>');
  cxSetResourceString(@cxSFilterControlNullString, '<��>');
  //'<empty>');

  cxSetResourceString(@cxSFilterErrorBuilding, '���ܴ�Դ��������');
  //'Can''t build filter from source');

  //FilterDialog
  cxSetResourceString(@cxSFilterDialogCaption, '���ƹ���');
  //'Custom Filter');
  cxSetResourceString(@cxSFilterDialogInvalidValue, '����ֵ�Ƿ�');
  //'Invalid value');
  cxSetResourceString(@cxSFilterDialogUse, 'ʹ��');
  //'Use');
  cxSetResourceString(@cxSFilterDialogSingleCharacter, '��ʾ�κε����ַ�');
  //'to represent any single character');
  cxSetResourceString(@cxSFilterDialogCharactersSeries, '��ʾ�����ַ�');
  //'to represent any series of characters');
  cxSetResourceString(@cxSFilterDialogOperationAnd, '����');
  //'AND');
  cxSetResourceString(@cxSFilterDialogOperationOr, '����');
  //'OR');
  cxSetResourceString(@cxSFilterDialogRows, '��ʾ������:');
  //'Show rows where:');

  // FilterControlDialog
  cxSetResourceString(@cxSFilterControlDialogCaption, '����������');
  //'Filter builder');
  cxSetResourceString(@cxSFilterControlDialogNewFile, 'δ����.flt');
  //'untitled.flt');
  cxSetResourceString(@cxSFilterControlDialogOpenDialogCaption, '��һ���Ѵ��ļ�');
  cxSetResourceString(@cxSFilterControlDialogSaveDialogCaption, '���浱ǰ��ļ�'); //'Save the active filter to file');
  cxSetResourceString(@cxSFilterControlDialogActionSaveCaption, '���');
  cxSetResourceString(@cxSFilterControlDialogActionOpenCaption, '��');
  cxSetResourceString(@cxSFilterControlDialogActionApplyCaption, 'Ӧ��');
  cxSetResourceString(@cxSFilterControlDialogActionOkCaption, 'ȷ��');
  //'OK');
  cxSetResourceString(@cxSFilterControlDialogActionCancelCaption, 'ȡ��');
  cxSetResourceString(@cxSFilterControlDialogFileExt, 'flt');
  //'flt');
  cxSetResourceString(@cxSFilterControlDialogFileFilter, '�����ļ� (*.flt)|*.flt');
                                                                                
  //cxEditConsts.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@cxSEditButtonCancel, 'ȡ��');
  //sdl//'Cancel'
  cxSetResourceString(@cxSEditButtonOK, 'ȷ��');
  //sdl//'OK'
  cxSetResourceString(@cxSEditDateConvertError, 'Could not convert to date');
  cxSetResourceString(@cxSEditInvalidRepositoryItem, '�˲ֿ���Ŀ���ɽ���');
  ////'The repository item is not acceptable');
  cxSetResourceString(@cxSEditNumericValueConvertError, '����ת��������');
  ////'Could not convert to numeric value');
  cxSetResourceString(@cxSEditPopupCircularReferencingError, '������ѭ������');
  ////'Circular referencing is not allowed');
  cxSetResourceString(@cxSEditPostError, '���ύ�༭ֵʱ��������');
  ////'An error occured during posting edit value');
  cxSetResourceString(@cxSEditTimeConvertError, '����ת����ʱ��');
  ////'Could not convert to time');
  cxSetResourceString(@cxSEditValidateErrorText, '����ȷ������ֵ. ʹ��ESC�������ı�');
  ////'Invalid input value. Use escape key to abandon changes');
  cxSetResourceString(@cxSEditValueOutOfBounds, 'ֵ������Χ');
  ////'Value out of bounds');

  // TODO
  cxSetResourceString(@cxSEditCheckBoxChecked, '��');
  ////'True');
  cxSetResourceString(@cxSEditCheckBoxGrayed, '');
  ////'');
  cxSetResourceString(@cxSEditCheckBoxUnchecked, '��');
  ////'False');
  cxSetResourceString(@cxSRadioGroupDefaultCaption, '');
  ////'');

  cxSetResourceString(@cxSTextTrue, '��');
  ////'True');
  cxSetResourceString(@cxSTextFalse, '��');
  ////'False');

  // blob
  cxSetResourceString(@cxSBlobButtonOK, 'ȷ��(&O)');
  ////'&OK');
  cxSetResourceString(@cxSBlobButtonCancel, 'ȡ��(&C)');
  ////'&Cancel');
  cxSetResourceString(@cxSBlobButtonClose, '�ر�(&C)');
  ////'&Close');
  cxSetResourceString(@cxSBlobMemo, '(�ı�)');
  ////'(MEMO)');
  cxSetResourceString(@cxSBlobMemoEmpty, '(���ı�)');
  ////'(memo)');
  cxSetResourceString(@cxSBlobPicture, '(ͼ��)');
  ////'(PICTURE)');
  cxSetResourceString(@cxSBlobPictureEmpty, '(��ͼ��)');
  ////'(picture)');

  // popup menu items
  cxSetResourceString(@cxSMenuItemCaptionCut, '����(&T)');
  ////'Cu&t');
  cxSetResourceString(@cxSMenuItemCaptionCopy, '����(&C)');
  ////'&Copy');
  cxSetResourceString(@cxSMenuItemCaptionPaste, 'ճ��(&P)');
  ////'&Paste');
  cxSetResourceString(@cxSMenuItemCaptionDelete, 'ɾ��(&D)');
  ////'&Delete');
  cxSetResourceString(@cxSMenuItemCaptionLoad, 'װ��(&L)...');
  ////'&Load...');
  cxSetResourceString(@cxSMenuItemCaptionSave, '���Ϊ(&A)...');
  ////'Save &As...');

  // date
  cxSetResourceString(@cxSDatePopupClear, '���');
  ////'Clear');
  cxSetResourceString(@cxSDatePopupNow, '����');
  cxSetResourceString(@cxSDatePopupOK, 'ȷ��');
  cxSetResourceString(@cxSDatePopupToday, '����');
  ////'Today');
  cxSetResourceString(@cxSDateError, '�Ƿ�����');
  ////'Invalid Date');
  // smart input consts
  cxSetResourceString(@cxSDateToday, '����');
  ////'today');
  cxSetResourceString(@cxSDateYesterday, '����');
  ////'yesterday');
  cxSetResourceString(@cxSDateTomorrow, '����');
  ////'tomorrow');
  cxSetResourceString(@cxSDateSunday, '��');
  ////'Sunday');
  cxSetResourceString(@cxSDateMonday, 'һ');
  ////'Monday');
  cxSetResourceString(@cxSDateTuesday, '��');
  ////'Tuesday');
  cxSetResourceString(@cxSDateWednesday, '��');
  ////'Wednesday');
  cxSetResourceString(@cxSDateThursday, '��');
  ////'Thursday');
  cxSetResourceString(@cxSDateFriday, '��');
  ////'Friday');
  cxSetResourceString(@cxSDateSaturday, '��');
  ////'Saturday');
  cxSetResourceString(@cxSDateFirst, '��һ');
  ////'first');
  cxSetResourceString(@cxSDateSecond, '�ڶ�');
  ////'second');
  cxSetResourceString(@cxSDateThird, '����');
  ////'third');
  cxSetResourceString(@cxSDateFourth, '����');
  ////'fourth');
  cxSetResourceString(@cxSDateFifth, '����');
  ////'fifth');
  cxSetResourceString(@cxSDateSixth, '����');
  ////'sixth');
  cxSetResourceString(@cxSDateSeventh, '����');
  ////'seventh');
  cxSetResourceString(@cxSDateBOM, '�³�');
  ////'bom');
  cxSetResourceString(@cxSDateEOM, '��ĩ');
  ////'eom');
  cxSetResourceString(@cxSDateNow, '����');
  ////'now');

  // calculator
  cxSetResourceString(@scxSCalcError, '����');
  ////'Error'

  // HyperLink
  cxSetResourceString(@scxSHyperLinkPrefix, 'http://');
  cxSetResourceString(@scxSHyperLinkDoubleSlash, '//');

  // edit repository
  cxSetResourceString(@scxSEditRepositoryBlobItem, 'BlobEdit|Represents the BLOB editor');
  cxSetResourceString(@scxSEditRepositoryButtonItem, 'ButtonEdit|Represents an edit control with embedded buttons');
  cxSetResourceString(@scxSEditRepositoryCalcItem, 'CalcEdit|Represents an edit control with a dropdown calculator window');
  cxSetResourceString(@scxSEditRepositoryCheckBoxItem, 'CheckBox|Represents a check box control that allows selecting an option');
  cxSetResourceString(@scxSEditRepositoryComboBoxItem, 'ComboBox|Represents the combo box editor');
  cxSetResourceString(@scxSEditRepositoryCurrencyItem, 'CurrencyEdit|Represents an editor enabling editing currency data');
  cxSetResourceString(@scxSEditRepositoryDateItem, 'DateEdit|Represents an edit control with a dropdown calendar');
  cxSetResourceString(@scxSEditRepositoryHyperLinkItem, 'HyperLink|Represents a text editor with hyperlink functionality');
  cxSetResourceString(@scxSEditRepositoryImageComboBoxItem,
    'ImageComboBox|Represents an editor displaying the list of images and text strings within the dropdown window');
  cxSetResourceString(@scxSEditRepositoryImageItem, 'Image|Represents an image editor');
  cxSetResourceString(@scxSEditRepositoryLookupComboBoxItem, 'LookupComboBox|Represents a lookup combo box control');
  cxSetResourceString(@scxSEditRepositoryMaskItem, 'MaskEdit|Represents a generic masked edit control.');
  cxSetResourceString(@scxSEditRepositoryMemoItem, 'Memo|Represents an edit control that allows editing memo data');
  cxSetResourceString(@scxSEditRepositoryMRUItem,
    'MRUEdit|Represents a text editor displaying the list of most recently used items (MRU) within a dropdown window');
  cxSetResourceString(@scxSEditRepositoryPopupItem, 'PopupEdit|Represents an edit control with a dropdown list');
  cxSetResourceString(@scxSEditRepositorySpinItem, 'SpinEdit|Represents a spin editor');
  cxSetResourceString(@scxSEditRepositoryRadioGroupItem, 'RadioGroup|Represents a group of radio buttons');
  cxSetResourceString(@scxSEditRepositoryTextItem, 'TextEdit|Represents a single line text editor');
  cxSetResourceString(@scxSEditRepositoryTimeItem, 'TimeEdit|Represents an editor displaying time values');

  cxSetResourceString(@scxRegExprLine, '��');
  ////'Line');
  cxSetResourceString(@scxRegExprChar, '�ַ�');
  ////'Char');
  cxSetResourceString(@scxRegExprNotAssignedSourceStream, '��Դ��û�б���ֵ');
  ////'The source stream is not assigned');
  cxSetResourceString(@scxRegExprEmptySourceStream, '��Դ���ǿյ�');
  ////'The source stream is empty');
  cxSetResourceString(@scxRegExprCantUsePlusQuantifier, '���� ''+'' ����Ӧ�õ���');
  ////'The ''+'' quantifier cannot be applied here');
  cxSetResourceString(@scxRegExprCantUseStarQuantifier, '���� ''*'' ����Ӧ�õ���');
  ////'The ''*'' quantifier cannot be applied here');
  cxSetResourceString(@scxRegExprCantCreateEmptyAlt, '������һ����Ϊ��');
  ////'The alternative should not be empty');
  cxSetResourceString(@scxRegExprCantCreateEmptyBlock, '�˿�Ӧ��Ϊ��');
  ////'The block should not be empty');
  cxSetResourceString(@scxRegExprIllegalSymbol, '���Ϲ涨�� ''%s''');
  ////'Illegal ''%s''');
  cxSetResourceString(@scxRegExprIllegalQuantifier, '���Ϲ涨������ ''%s''');
  ////'Illegal quantifier ''%s''');
  cxSetResourceString(@scxRegExprNotSupportQuantifier, '�˲������ʲ�֧��');
  ////'The parameter quantifiers are not supported');
  cxSetResourceString(@scxRegExprIllegalIntegerValue, '���Ϸ�������ֵ');
  ////'Illegal integer value');
  cxSetResourceString(@scxRegExprTooBigReferenceNumber, '������̫��');
  ////'Too big reference number');
  cxSetResourceString(@scxRegExprCantCreateEmptyEnum, '���ܴ����յ�ö��ֵ');
  ////'Can''t create empty enumeration');
  cxSetResourceString(@scxRegExprSubrangeOrder, '�Ӵ��Ŀ�ʼ�ַ�λ�ò��ܳ��������ַ�λ��');
  ////'The starting character of the subrange must be less than the finishing one');
  cxSetResourceString(@scxRegExprHexNumberExpected0, '�ڴ�ʮ��������');
  ////'Hexadecimal number expected');
  cxSetResourceString(@scxRegExprHexNumberExpected, '�ڴ�ʮ����������λ�÷����� ''%s'' ');
  ////'Hexadecimal number expected but ''%s'' found');
  cxSetResourceString(@scxRegExprMissing, 'ȱ�� ''%s''');
  ////'Missing ''%s''');
  cxSetResourceString(@scxRegExprUnnecessary, '����Ҫ�� ''%s''');
  ////'Unnecessary ''%s''');
  cxSetResourceString(@scxRegExprIncorrectSpace, '�� ''\'' ���ܳ��ֿո��ַ�');
  ////'The space character is not allowed after ''\''');
  cxSetResourceString(@scxRegExprNotCompiled, '������ʽ���ܱ���');
  ////'Regular expression is not compiled');
  cxSetResourceString(@scxRegExprIncorrectParameterQuantifier, '����Ĳ���');
  ////'Incorrect parameter quantifier');
  cxSetResourceString(@scxRegExprCantUseParameterQuantifier, '�˲�������Ӧ���ڴ˴�');
  ////'The parameter quantifier cannot be applied here');

  cxSetResourceString(@scxMaskEditRegExprError, '������ʽ����:');
  ////'Regular expression errors:');
  cxSetResourceString(@scxMaskEditInvalidEditValue, '�༭ֵ�Ƿ�');
  ////'The edit value is invalid');
  cxSetResourceString(@scxMaskEditNoMask, 'û��');
  ////'None');
  cxSetResourceString(@scxMaskEditIllegalFileFormat, '�ļ���ʽ�Ƿ�');
  ////'Illegal file format');
  cxSetResourceString(@scxMaskEditEmptyMaskCollectionFile, '�����ʽ�ļ�Ϊ��');
  ////'The mask collection file is empty');
  cxSetResourceString(@scxMaskEditMaskCollectionFiles, '�����ʽ�ļ�');
  ////'Mask collection files');
  cxSetResourceString(@cxSSpinEditInvalidNumericValue, 'Invalid numeric value');

  //dxPSRes.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@sdxBtnOK,'ȷ��(&O)');
  ////'OK');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxBtnOKAccelerated,'ȷ��(&O');
  ////'&OK');                                                                                                                                                                                                       
  cxSetResourceString(@sdxBtnCancel,'ȡ��');
  ////'Cancel');                                                                                                                                                                                                              
  cxSetResourceString(@sdxBtnClose,'�ر�');
  ////'Close');                                                                                                                                                                                                                
  cxSetResourceString(@sdxBtnApply,'Ӧ��(&A)');
  ////'&Apply');                                                                                                                                                                                                           
  cxSetResourceString(@sdxBtnHelp,'����(&H)');
  ////'&Help');                                                                                                                                                                                                             
  cxSetResourceString(@sdxBtnFix,'����(&F)');
  ////'&Fix');                                                                                                                                                                                                               
  cxSetResourceString(@sdxBtnNew,'�½�(&N)...');
  ////'&New...');                                                                                                                                                                                                         
  cxSetResourceString(@sdxBtnIgnore,'����(&I)');
  ////'&Ignore');                                                                                                                                                                                                         
  cxSetResourceString(@sdxBtnYes,'��(&Y)');
  ////'&Yes');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnNo,'��(&N)');
  ////'&No');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxBtnEdit,'�༭(&E)...');
  ////'&Edit...');                                                                                                                                                                                                       
  cxSetResourceString(@sdxBtnReset,'��λ(&R)');
  ////'&Reset');                                                                                                                                                                                                           
  cxSetResourceString(@sdxBtnAdd,'����(&A');
  ////'&Add');                                                                                                                                                                                                                
  cxSetResourceString(@sdxBtnAddComposition,'���Ӳ���(&C)');
  ////'Add &Composition');                                                                                                                                                                                    
  cxSetResourceString(@sdxBtnDefault,'Ĭ��(&D)...');
  ////'&Default...');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnDelete,'ɾ��(&D)...');
  ////'&Delete...');                                                                                                                                                                                                   
  cxSetResourceString(@sdxBtnDescription,'����(&D)...');
  ////'&Description...');                                                                                                                                                                                         
  cxSetResourceString(@sdxBtnCopy,'����(&C)...');
  ////'&Copy...');                                                                                                                                                                                                       
  cxSetResourceString(@sdxBtnYesToAll,'ȫ����(&A)');
  ////'Yes To &All');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnRestoreDefaults,'�ָ�Ĭ��ֵ(&R)');
  ////'&Restore Defaults');                                                                                                                                                                                
  cxSetResourceString(@sdxBtnRestoreOriginal,'��ԭ(&O)');
  ////'Restore &Original');                                                                                                                                                                                      
  cxSetResourceString(@sdxBtnTitleProperties,'��������...');
  ////'Title Properties...');                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnProperties,'����(&R)...');
  ////'P&roperties...');                                                                                                                                                                                           
  cxSetResourceString(@sdxBtnNetwork,'����(&W)...');
  ////'Net&work...');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnBrowse,'���(&B)...');
  ////'&Browse...');                                                                                                                                                                                                   
  cxSetResourceString(@sdxBtnPageSetup,'ҳ������(&G)...');
  ////'Pa&ge Setup...');                                                                                                                                                                                        
  cxSetResourceString(@sdxBtnPrintPreview,'��ӡԤ��(&V)...');
  ////'Print Pre&view...');                                                                                                                                                                                  
  cxSetResourceString(@sdxBtnPreview,'Ԥ��(&V)...');
  ////'Pre&view...');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnPrint,'��ӡ...');
  ////'Print...');                                                                                                                                                                                                          
  cxSetResourceString(@sdxBtnOptions,'ѡ��(&O)...');
  ////'&Options...');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnStyleOptions,'��ʽѡ��...');
  ////'Style Options...');                                                                                                                                                                                       
  cxSetResourceString(@sdxBtnDefinePrintStyles,'������ʽ(&D)...');
  ////'&Define Styles...');                                                                                                                                                                             
  cxSetResourceString(@sdxBtnPrintStyles,'��ӡ��ʽ');
  ////'Print Styles');                                                                                                                                                                                               
  cxSetResourceString(@sdxBtnBackground,'����');
  ////'Background');                                                                                                                                                                                                      
  cxSetResourceString(@sdxBtnShowToolBar,'��ʾ������(&T)');
  ////'Show &ToolBar');                                                                                                                                                                                        
  cxSetResourceString(@sdxBtnDesign,'���(&E)...');
  ////'D&esign...');                                                                                                                                                                                                   
  cxSetResourceString(@sdxBtnMoveUp,'����(&U)');
  ////'Move &Up');                                                                                                                                                                                                        
  cxSetResourceString(@sdxBtnMoveDown,'����(&N)');
  ////'Move Dow&n'); 

  cxSetResourceString(@sdxBtnMoreColors,'������ɫ(&M)...');
  ////'&More Colors...');                                                                                                                                                                                      
  cxSetResourceString(@sdxBtnFillEffects,'���Ч��(&F)...');
  ////'&Fill Effects...');                                                                                                                                                                                    
  cxSetResourceString(@sdxBtnNoFill,'�����');
  ////'&No Fill');                                                                                                                                                                                                          
  cxSetResourceString(@sdxBtnAutomatic,'�Զ�(&A)');
  ////'&Automatic');                                                                                                                                                                                                   
  cxSetResourceString(@sdxBtnNone,'��(&N)');
  ////'&None'); 

  cxSetResourceString(@sdxBtnOtherTexture,'��������(&X)...');
  ////'Other Te&xture...');                                                                                                                                                                                  
  cxSetResourceString(@sdxBtnInvertColors,'��ת��ɫ(&N)');
  ////'I&nvert Colors');                                                                                                                                                                                        
  cxSetResourceString(@sdxBtnSelectPicture,'ѡ��ͼƬ(&L)...');
  ////'Se&lect Picture...'); 

  cxSetResourceString(@sdxEditReports,'�༭����');
  ////'Edit Reports');                                                                                                                                                                                                  
  cxSetResourceString(@sdxComposition,'����');
  ////'Composition');                                                                                                                                                                                                       
  cxSetResourceString(@sdxReportTitleDlgCaption,'�������');
  ////'Report Title');                                                                                                                                                                                        
  cxSetResourceString(@sdxMode,'ģʽ(&M):');
  ////'&Mode:');                                                                                                                                                                                                              
  cxSetResourceString(@sdxText,'����(&T)');
  ////'&Text');                                                                                                                                                                                                                
  cxSetResourceString(@sdxProperties,'����(&P)');
  ////'&Properties');                                                                                                                                                                                                    
  cxSetResourceString(@sdxAdjustOnScale,'�ʺ�ҳ��(&A)');
  ////'&Adjust on Scale');                                                                                                                                                                                        
  cxSetResourceString(@sdxTitleModeNone,'��');
  ////'None');                                                                                                                                                                                                              
  cxSetResourceString(@sdxTitleModeOnEveryTopPage,'��ÿ�Ŷ�ҳ');
  ////'On Every Top Page');                                                                                                                                                                               
  cxSetResourceString(@sdxTitleModeOnFirstPage,'�ڵ�һҳ');
  ////'On First Page'); 

  cxSetResourceString(@sdxEditDescription,'�༭����');
  ////'Edit Description');                                                                                                                                                                                          
  cxSetResourceString(@sdxRename,'������(&M)');
  ////'Rena&me');                                                                                                                                                                                                          
  cxSetResourceString(@sdxSelectAll,'ȫѡ');
  ////'&Select All'); 
  
  cxSetResourceString(@sdxAddReport,'���ӱ���');
  ////'Add Report');                                                                                                                                                                                                      
  cxSetResourceString(@sdxAddAndDesignReport,'���Ӳ���Ʊ���(&D)...');
  ////'Add and D&esign Report...');                                                                                                                                                                 
  cxSetResourceString(@sdxNewCompositionCaption,'�½�����');
  ////'New Composition');                                                                                                                                                                                     
  cxSetResourceString(@sdxName,'����(&N):');
  ////'&Name:');                                                                                                                                                                                                              
  cxSetResourceString(@sdxCaption,'����(&C):');
  ////'&Caption:');                                                                                                                                                                                                        
  cxSetResourceString(@sdxAvailableSources,'���õ�Դ(&A)');
  ////'&Available Source(s)');                                                                                                                                                                                 
  cxSetResourceString(@sdxOnlyComponentsInActiveForm,'ֻ��ʾ��ǰ�������');
  ////'Only Components in Active &Form');                                                                                                                                                    
  cxSetResourceString(@sdxOnlyComponentsWithoutLinks,'ֻ��ʾ�����б���������������');
  ////'Only Components &without Existing ReportLinks');                                                                                                                            
  cxSetResourceString(@sdxItemName,'����');
  ////'Name');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxItemDescription,'����');
  ////'Description');
    
  cxSetResourceString(@sdxConfirmDeleteItem,'Ҫɾ����һ����Ŀ�� %s ��?');
  ////'Do you want to delete next items: %s ?');                                                                                                                                                 
  cxSetResourceString(@sdxAddItemsToComposition,'������Ŀ������');
  ////'Add Items to Composition');                                                                                                                                                                      
  cxSetResourceString(@sdxHideAlreadyIncludedItems,'�����Ѱ�����Ŀ');
  ////'Hide Already &Included Items');                                                                                                                                                               
  cxSetResourceString(@sdxAvailableItems,'������Ŀ(&I)');
  ////'A&vailable Items');                                                                                                                                                                                       
  cxSetResourceString(@sdxItems,'��Ŀ(&I)');
  ////'&Items');                                                                                                                                                                                                              
  cxSetResourceString(@sdxEnable,'����(&E)');
  ////'&Enable');                                                                                                                                                                                                            
  cxSetResourceString(@sdxOptions,'ѡ��');
  ////'Options');                                                                                                                                                                                                               
  cxSetResourceString(@sdxShow,'��ʾ');
  ////'Show');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxPaintItemsGraphics,'������Ŀͼʾ(&P)');
  ////'&Paint Item Graphics');                                                                                                                                                                           
  cxSetResourceString(@sdxDescription,'����:');
  ////'&Description:');

  cxSetResourceString(@sdxNewReport,'�±���');
  ////'NewReport');
    
  cxSetResourceString(@sdxOnlySelected,'ֻ��ѡ����(&S)');
  ////'Only &Selected');                                                                                                                                                                                         
  cxSetResourceString(@sdxExtendedSelect,'��չѡ����(&E)');
  ////'&Extended Select');                                                                                                                                                                                     
  cxSetResourceString(@sdxIncludeFixed,'�����̶���(&I)');
  ////'&Include Fixed');

  cxSetResourceString(@sdxFonts,'����');
  ////'Fonts');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxBtnFont,'����(&N)...');
  ////'Fo&nt...');                                                                                                                                                                                                       
  cxSetResourceString(@sdxBtnEvenFont,'ż��������(&V)...');
  ////'E&ven Font...');                                                                                                                                                                                        
  cxSetResourceString(@sdxBtnOddFont,'����������(&N)...');
  ////'Odd Fo&nt...');                                                                                                                                                                                          
  cxSetResourceString(@sdxBtnFixedFont,'�̶�������(&I)...');
  ////'F&ixed Font...');                                                                                                                                                                                      
  cxSetResourceString(@sdxBtnGroupFont,'������(&P)...');
  ////'Grou&p Font...');                                                                                                                                                                                          
  cxSetResourceString(@sdxBtnChangeFont,'��������(&N)...');
  ////'Change Fo&nt...');

  cxSetResourceString(@sdxFont,'����');
  ////'Font');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxOddFont,'����������');
  ////'Odd Font');                                                                                                                                                                                                        
  cxSetResourceString(@sdxEvenFont,'ż��������');
  ////'Even Font');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPreviewFont,'Ԥ������');
  ////'Preview Font');                                                                                                                                                                                                  
  cxSetResourceString(@sdxCaptionNodeFont,'��α�������');
  ////'Level Caption Font');                                                                                                                                                                                    
  cxSetResourceString(@sdxGroupNodeFont,'��ڵ�����');
  ////'Group Node Font');                                                                                                                                                                                           
  cxSetResourceString(@sdxGroupFooterFont,'�������');
  ////'Group Footer Font');                                                                                                                                                                                         
  cxSetResourceString(@sdxHeaderFont,'ҳü����');
  ////'Header Font');                                                                                                                                                                                                    
  cxSetResourceString(@sdxFooterFont,'ҳ������');
  ////'Footer Font');                                                                                                                                                                                                    
  cxSetResourceString(@sdxBandFont,'��������');
  ////'Band Font');

  cxSetResourceString(@sdxTransparent,'͸��(&T)');
  ////'&Transparent');                                                                                                                                                                                                  
  cxSetResourceString(@sdxFixedTransparent,'͸��(&X)');
  ////'Fi&xed Transparent');                                                                                                                                                                                       
  cxSetResourceString(@sdxCaptionTransparent,'����͸��');
  ////'Caption Transparent');                                                                                                                                                                                    
  cxSetResourceString(@sdxGroupTransparent,'��͸��');
  ////'Group Transparent'); 

  cxSetResourceString(@sdxGraphicAsTextValue,'(ͼ��)');
  ////'(GRAPHIC)');                                                                                                                                                                                                
  cxSetResourceString(@sdxColors,'��ɫ');
  ////'Colors');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxColor,'��ɫ(&L):');
  ////'Co&lor:');                                                                                                                                                                                                            
  cxSetResourceString(@sdxOddColor,'��������ɫ(&L):');
  ////'Odd Co&lor:');                                                                                                                                                                                               
  cxSetResourceString(@sdxEvenColor,'ż������ɫ(&V):');
  ////'E&ven Color:');                                                                                                                                                                                             
  cxSetResourceString(@sdxPreviewColor,'Ԥ����ɫ(&P):');
  ////'&Preview Color:');                                                                                                                                                                                         
  cxSetResourceString(@sdxBandColor,'������ɫ(&B):');
  ////'&Band Color:');                                                                                                                                                                                               
  cxSetResourceString(@sdxLevelCaptionColor,'��α�����ɫ(&V):');
  ////'Le&vel Caption Color:');                                                                                                                                                                          
  cxSetResourceString(@sdxHeaderColor,'������ɫ(&E):');
  ////'H&eader Color:');                                                                                                                                                                                           
  cxSetResourceString(@sdxGroupNodeColor,'��ڵ���ɫ(&N):');
  ////'Group &Node Color:');                                                                                                                                                                                  
  cxSetResourceString(@sdxGroupFooterColor,'�����ɫ(&G):');
  ////'&Group Footer Color:');                                                                                                                                                                                
  cxSetResourceString(@sdxFooterColor,'ҳ����ɫ(&T):');
  ////'Foo&ter Color:');                                                                                                                                                                                           
  cxSetResourceString(@sdxFixedColor,'�̶���ɫ(&I):');
  ////'F&ixed Color:');                                                                                                                                                                                             
  cxSetResourceString(@sdxGroupColor,'����ɫ(&I):');
  ////'Grou&p Color:');                                                                                                                                                                                               
  cxSetResourceString(@sdxCaptionColor,'������ɫ:');
  ////'Caption Color:');                                                                                                                                                                                              
  cxSetResourceString(@sdxGridLinesColor,'��������ɫ(&D):');
  ////'Gri&d Line Color:');

  cxSetResourceString(@sdxBands,'����(&B)');
  ////'&Bands');                                                                                                                                                                                                              
  cxSetResourceString(@sdxLevelCaptions,'��α���(&C)');
  ////'Levels &Caption');                                                                                                                                                                                         
  cxSetResourceString(@sdxHeaders,'ҳü(&E)');
  ////'H&eaders');                                                                                                                                                                                                          
  cxSetResourceString(@sdxFooters,'ҳ��(&R)');
  ////'Foote&rs');                                                                                                                                                                                                          
  cxSetResourceString(@sdxGroupFooters,'���(&G)');
  ////'&Group Footers');                                                                                                                                                                                               
  cxSetResourceString(@sdxPreview,'Ԥ��(&W)');
  ////'Previe&w');                                                                                                                                                                                                          
  cxSetResourceString(@sdxPreviewLineCount,'Ԥ������(&T):');
  ////'Preview Line Coun&t:');                                                                                                                                                                                
  cxSetResourceString(@sdxAutoCalcPreviewLineCount,'�Զ�����Ԥ������(&U)');
  ////'A&uto Calculate Preview Lines');

  cxSetResourceString(@sdxGrid,'����(&D)');
  ////'Grid Lines');                                                                                                                                                                                                           
  cxSetResourceString(@sdxNodesGrid,'�ڵ�����(&N)');
  ////'Node Grid Lines');                                                                                                                                                                                             
  cxSetResourceString(@sdxGroupFooterGrid,'�������(&P)');
  ////'GroupFooter Grid Lines');                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxStateImages,'״̬ͼ��(&S)');
  ////'&State Images');                                                                                                                                                                                             
  cxSetResourceString(@sdxImages,'ͼ��(&I)');
  ////'&Images'); 

  cxSetResourceString(@sdxTextAlign,'�ı�����(&A)');
  ////'Text&Align');                                                                                                                                                                                                  
  cxSetResourceString(@sdxTextAlignHorz,'ˮƽ(&Z)');
  ////'Hori&zontally');                                                                                                                                                                                               
  cxSetResourceString(@sdxTextAlignVert,'��ֱ(&V)');
  ////'&Vertically');                                                                                                                                                                                                 
  cxSetResourceString(@sdxTextAlignLeft,'����');
  ////'Left');                                                                                                                                                                                                            
  cxSetResourceString(@sdxTextAlignCenter,'����');
  ////'Center');                                                                                                                                                                                                        
  cxSetResourceString(@sdxTextAlignRight,'����');
  ////'Right');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTextAlignTop,'����');
  ////'Top');                                                                                                                                                                                                              
  cxSetResourceString(@sdxTextAlignVCenter,'����');
  ////'Center');                                                                                                                                                                                                       
  cxSetResourceString(@sdxTextAlignBottom,'�ײ�');
  ////'Bottom');                                                                                                                                                                                                        
  cxSetResourceString(@sdxBorderLines,'�߿�����(&B)');
  ////'&Border');                                                                                                                                                                                                   
  cxSetResourceString(@sdxHorzLines,'ˮƽ��(&Z)');
  ////'Hori&zontal Lines');                                                                                                                                                                                             
  cxSetResourceString(@sdxVertLines,'��ֱ��(&V)');
  ////'&Vertical Lines');                                                                                                                                                                                               
  cxSetResourceString(@sdxFixedHorzLines,'�̶�ˮƽ��(&X)');
  ////'Fi&xed Horizontal Lines');                                                                                                                                                                              
  cxSetResourceString(@sdxFixedVertLines,'�̶���ֱ��(&D)');
  ////'Fixe&d Vertical Lines');                                                                                                                                                                                
  cxSetResourceString(@sdxFlatCheckMarks,'ƽ�����(&L)');
  ////'F&lat CheckMarks');                                                                                                                                                                                     
  cxSetResourceString(@sdxCheckMarksAsText,'���ı���ʾ����(&D)');
  ////'&Display CheckMarks as Text');

  cxSetResourceString(@sdxRowAutoHeight,'�Զ������и�(&W)');
  ////'Ro&w AutoHeight');                                                                                                                                                                                     
  cxSetResourceString(@sdxEndEllipsis,'����ʡ�Է�(&E)');
  ////'&EndEllipsis');                                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxDrawBorder,'���Ʊ߿�(&D)');
  ////'&Draw Border');                                                                                                                                                                                               
  cxSetResourceString(@sdxFullExpand,'��ȫչ��(&E)');
  ////'Full &Expand');                                                                                                                                                                                               
  cxSetResourceString(@sdxBorderColor,'�߿���ɫ(&B):');
  ////'&Border Color:');                                                                                                                                                                                           
  cxSetResourceString(@sdxAutoNodesExpand,'�Զ�չ���ڵ�(&U)');
  ////'A&uto Nodes Expand');                                                                                                                                                                                
  cxSetResourceString(@sdxExpandLevel,'չ�����(&L):');
  ////'Expand &Level:');                                                                                                                                                                                           
  cxSetResourceString(@sdxFixedRowOnEveryPage,'�̶�ÿҳ����(&E)');
  ////'Fixed Rows');

  cxSetResourceString(@sdxDrawMode,'����ģʽ(&M):');
  ////'Draw &Mode:');                                                                                                                                                                                                 
  cxSetResourceString(@sdxDrawModeStrict,'��ȷ');
  ////'Strict');                                                                                                                                                                                                         
  cxSetResourceString(@sdxDrawModeOddEven,'��/ż��ģʽ');
  ////'Odd/Even Rows Mode');                                                                                                                                                                                     
  cxSetResourceString(@sdxDrawModeChess,'��������ģʽ');
  ////'Chess Mode');                                                                                                                                                                                              
  cxSetResourceString(@sdxDrawModeBorrow,'��Դ����');
  ////'Borrow From Source');                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdx3DEffects,'��άЧ��');
  ////'3D Effects');                                                                                                                                                                                                      
  cxSetResourceString(@sdxUse3DEffects,'ʹ����άЧ��(&3)');
  ////'Use &3D Effects');                                                                                                                                                                                      
  cxSetResourceString(@sdxSoft3D,'�����ά(&3)');
  ////'Sof&t3D');                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxBehaviors,'����');
  ////'Behaviors');                                                                                                                                                                                                           
  cxSetResourceString(@sdxMiscellaneous,'����');
  ////'Miscellaneous');                                                                                                                                                                                                   
  cxSetResourceString(@sdxOnEveryPage,'��ÿҳ');
  ////'On Every Page');                                                                                                                                                                                                   
  cxSetResourceString(@sdxNodeExpanding,'չ���ڵ�');
  ////'Node Expanding');                                                                                                                                                                                              
  cxSetResourceString(@sdxSelection,'ѡ��');
  ////'Selection');                                                                                                                                                                                                           
  cxSetResourceString(@sdxNodeAutoHeight,'�ڵ��Զ������߶�(&N)');
  ////'&Node Auto Height');                                                                                                                                                                              
  cxSetResourceString(@sdxTransparentGraphics,'ͼ��͸��(&T)');
  ////'&Transparent Graphics');                                                                                                                                                                             
  cxSetResourceString(@sdxAutoWidth,'�Զ��������(&W)');
  ////'Auto &Width');                                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxDisplayGraphicsAsText,'���ı���ʽ��ʾͼ��(&T)');
  ////'Display Graphic As &Text');                                                                                                                                                              
  cxSetResourceString(@sdxTransparentColumnGraphics,'ͼ��͸��(&G)');
  ////'Transparent &Graphics');                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxBandsOnEveryPage,'ÿҳ��ʾ����');
  ////'Bands');                                                                                                                                                                                                
  cxSetResourceString(@sdxHeadersOnEveryPage,'ÿҳ��ʾҳü');
  ////'Headers');                                                                                                                                                                                            
  cxSetResourceString(@sdxFootersOnEveryPage,'ÿҳ��ʾҳ��');
  ////'Footers');                                                                                                                                                                                            
  cxSetResourceString(@sdxGraphics,'ͼ��');
  ////'&Graphics');

  { Common messages }
  
  cxSetResourceString(@sdxOutOfResources,'��Դ����');
  ////'Out of Resources');                                                                                                                                                                                           
  cxSetResourceString(@sdxFileAlreadyExists,'�ļ� "%s" �Ѿ����ڡ�');
  ////'File "%s" Already Exists.');                                                                                                                                                                   
  cxSetResourceString(@sdxConfirmOverWrite,'�ļ� "%s" �Ѿ����ڡ� ������ ?');
  ////'File "%s" already exists. Overwrite ?');                                                                                                                                               
  cxSetResourceString(@sdxInvalidFileName,'��Ч���ļ��� "%s"');
  ////'Invalid File Name "%s"');                                                                                                                                                                           
  cxSetResourceString(@sdxRequiredFileName,'�����ļ����ơ�');
  ////'Enter file name.'); 
  cxSetResourceString(@sdxOutsideMarginsMessage,
    'One or more margins are set outside the printable area of the page.' + #13#10 +
    'Do you want to continue ?');
  cxSetResourceString(@sdxOutsideMarginsMessage2,
    'One or more margins are set outside the printable area of the page.' + #13#10 +
    'Choose the Fix button to increase the appropriate margins.');
  cxSetResourceString(@sdxInvalidMarginsMessage,
    'One or more margins are set to the invalid values.' + #13#10 +
    'Choose the Fix button to correct this problem.' + #13#10 +
    'Choose the Restore button to restore original values.');
  cxSetResourceString(@sdxInvalidMargins,'һ������ҳ�߾�����Чֵ');
  ////'One or more margins has invalid values');                                                                                                                                                     
  cxSetResourceString(@sdxOutsideMargins,'һ������ҳ�߾೬��ҳ��Ŀɴ�ӡ����');
  ////'One or more margins are set outside the printable area of the page');                                                                                                             
  cxSetResourceString(@sdxThereAreNowItemsForShow,'û����Ŀ');
  ////'There are no items in this view');

  { Color palette }
  
  cxSetResourceString(@sdxPageBackground,' ҳ�汳��');
  ////' Page Background');                                                                                                                                                                                          
  cxSetResourceString(@sdxPenColor,'Ǧ����ɫ');
  ////'Pen Color');                                                                                                                                                                                                        
  cxSetResourceString(@sdxFontColor,'������ɫ');
  ////'Font Color');                                                                                                                                                                                                      
  cxSetResourceString(@sdxBrushColor,'ˢ����ɫ');
  ////'Brush Color');                                                                                                                                                                                                    
  cxSetResourceString(@sdxHighLight,'����');
  ////'HighLight');

  { Color names }
  
  cxSetResourceString(@sdxColorBlack,'��ɫ');
  ////'Black');                                                                                                                                                                                                              
  cxSetResourceString(@sdxColorDarkRed,'���');
  ////'Dark Red');                                                                                                                                                                                                         
  cxSetResourceString(@sdxColorRed,'��ɫ');
  ////'Red');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxColorPink,'�ۺ�');
  ////'Pink');                                                                                                                                                                                                                
  cxSetResourceString(@sdxColorRose,'õ���');
  ////'Rose');                                                                                                                                                                                                              
  cxSetResourceString(@sdxColorBrown,'��ɫ');
  ////'Brown');                                                                                                                                                                                                              
  cxSetResourceString(@sdxColorOrange,'�ۻ�');
  ////'Orange');                                                                                                                                                                                                            
  cxSetResourceString(@sdxColorLightOrange,'ǳ�ۻ�');
  ////'Light Orange');                                                                                                                                                                                               
  cxSetResourceString(@sdxColorGold,'��ɫ');
  ////'Gold');                                                                                                                                                                                                                
  cxSetResourceString(@sdxColorTan,'�ػ�');
  ////'Tan');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxColorOliveGreen,'�����');
  ////'Olive Green');                                                                                                                                                                                                 
  cxSetResourceString(@sdxColorDrakYellow,'���');
  ////'Dark Yellow');                                                                                                                                                                                                   
  cxSetResourceString(@sdxColorLime,'���ɫ');
  ////'Lime');                                                                                                                                                                                                              
  cxSetResourceString(@sdxColorYellow,'��ɫ');
  ////'Yellow');                                                                                                                                                                                                            
  cxSetResourceString(@sdxColorLightYellow,'ǳ��');
  ////'Light Yellow');                                                                                                                                                                                                 
  cxSetResourceString(@sdxColorDarkGreen,'����');
  ////'Dark Green');                                                                                                                                                                                                     
  cxSetResourceString(@sdxColorGreen,'��ɫ');
  ////'Green');                                                                                                                                                                                                              
  cxSetResourceString(@sdxColorSeaGreen,'����');
  ////'Sea Green');                                                                                                                                                                                                       
  cxSetResourceString(@sdxColorBrighthGreen,'����');
  ////'Bright Green');                                                                                                                                                                                                
  cxSetResourceString(@sdxColorLightGreen,'ǳ��');
  ////'Light Green');                                                                                                                                                                                                   
  cxSetResourceString(@sdxColorDarkTeal,'�����');
  ////'Dark Teal');                                                                                                                                                                                                     
  cxSetResourceString(@sdxColorTeal,'��ɫ');
  ////'Teal');                                                                                                                                                                                                                
  cxSetResourceString(@sdxColorAqua,'��ʯ��');
  ////'Aqua');                                                                                                                                                                                                              
  cxSetResourceString(@sdxColorTurquoise,'����');
  ////'Turquoise');                                                                                                                                                                                                      
  cxSetResourceString(@sdxColorLightTurquoise,'ǳ����');
  ////'Light Turquoise');                                                                                                                                                                                         
  cxSetResourceString(@sdxColorDarkBlue,'����');
  ////'Dark Blue');                                                                                                                                                                                                       
  cxSetResourceString(@sdxColorBlue,'��ɫ');
  ////'Blue');                                                                                                                                                                                                                
  cxSetResourceString(@sdxColorLightBlue,'ǳ��');
  ////'Light Blue');                                                                                                                                                                                                     
  cxSetResourceString(@sdxColorSkyBlue,'����');
  ////'Sky Blue');                                                                                                                                                                                                         
  cxSetResourceString(@sdxColorPaleBlue,'����');
  ////'Pale Blue');                                                                                                                                                                                                       
  cxSetResourceString(@sdxColorIndigo,'����');
  ////'Indigo');                                                                                                                                                                                                            
  cxSetResourceString(@sdxColorBlueGray,'��-��');
  ////'Blue Gray');                                                                                                                                                                                                      
  cxSetResourceString(@sdxColorViolet,'��ɫ');
  ////'Violet');                                                                                                                                                                                                            
  cxSetResourceString(@sdxColorPlum,'÷��');
  ////'Plum');                                                                                                                                                                                                                
  cxSetResourceString(@sdxColorLavender,'����');
  ////'Lavender');                                                                                                                                                                                                        
  cxSetResourceString(@sdxColorGray80,'��ɫ-80%');
  ////'Gray-80%');                                                                                                                                                                                                      
  cxSetResourceString(@sdxColorGray50,'��ɫ-50%');
  ////'Gray-50%');                                                                                                                                                                                                      
  cxSetResourceString(@sdxColorGray40,'��ɫ-40%');
  ////'Gray-40%');                                                                                                                                                                                                      
  cxSetResourceString(@sdxColorGray25,'��ɫ-25%');
  ////'Gray-25%');                                                                                                                                                                                                      
  cxSetResourceString(@sdxColorWhite,'��ɫ');
  ////'White');
 
  { FEF Dialog }
  
  cxSetResourceString(@sdxTexture,'����(&T)');
  ////'&Texture');                                                                                                                                                                                                          
  cxSetResourceString(@sdxPattern,'ͼ��(&P)');
  ////'&Pattern');                                                                                                                                                                                                          
  cxSetResourceString(@sdxPicture,'ͼƬ(&I)');
  ////'P&icture');                                                                                                                                                                                                          
  cxSetResourceString(@sdxForeground,'ǰ��(&F)');
  ////'&Foreground');                                                                                                                                                                                                    
  cxSetResourceString(@sdxBackground,'����(&B)');
  ////'&Background');                                                                                                                                                                                                    
  cxSetResourceString(@sdxSample,'ʾ��:');
  ////'Sample:');                                                                                                                                                                                                               
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxFEFCaption,'���Ч��');
  ////'Fill Effects');                                                                                                                                                                                                   
  cxSetResourceString(@sdxPaintMode,'��ͼģʽ');
  ////'Paint &Mode');                                                                                                                                                                                                     
  cxSetResourceString(@sdxPaintModeCenter,'����');
  ////'Center');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPaintModeStretch,'����');
  ////'Stretch');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPaintModeTile,'ƽ��');
  ////'Tile');                                                                                                                                                                                                            
  cxSetResourceString(@sdxPaintModeProportional,'��������');
  ////'Proportional');                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  { Pattern names }                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPatternGray5,'5%');
  ////'5%');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxPatternGray10,'10%');
  ////'10%');                                                                                                                                                                                                              
  cxSetResourceString(@sdxPatternGray20,'20%');
  ////'20%');                                                                                                                                                                                                              
  cxSetResourceString(@sdxPatternGray25,'25%');
  ////'25%');                                                                                                                                                                                                              
  cxSetResourceString(@sdxPatternGray30,'30%');
  ////'30%');                                                                                                                                                                                                              
  cxSetResourceString(@sdxPatternGray40,'40%');
  ////'40%');                                                                                                                                                                                                              
  cxSetResourceString(@sdxPatternGray50,'50%');
  ////'50%');                                                                                                                                                                                                              
  cxSetResourceString(@sdxPatternGray60,'60%');
  ////'60%');                                                                                                                                                                                                              
  cxSetResourceString(@sdxPatternGray70,'70%');
  ////'70%');                                                                                                                                                                                                              
  cxSetResourceString(@sdxPatternGray75,'75%');
  ////'75%');                                                                                                                                                                                                              
  cxSetResourceString(@sdxPatternGray80,'80%');
  ////'80%');                                                                                                                                                                                                              
  cxSetResourceString(@sdxPatternGray90,'90%');
  ////'90%');                                                                                                                                                                                                              
  cxSetResourceString(@sdxPatternLightDownwardDiagonal,'ǳɫ�¶Խ���');
  ////'Light downward diagonal');                                                                                                                                                                  
  cxSetResourceString(@sdxPatternLightUpwardDiagonal,'ǳɫ�϶Խ���');
  ////'Light upward diagonal');                                                                                                                                                                      
  cxSetResourceString(@sdxPatternDarkDownwardDiagonal,'��ɫ�¶Խ���');
  ////'Dark downward diagonal');                                                                                                                                                                    
  cxSetResourceString(@sdxPatternDarkUpwardDiagonal,'��ɫ�϶Խ���');
  ////'Dark upward diagonal');                                                                                                                                                                        
  cxSetResourceString(@sdxPatternWideDownwardDiagonal,'���¶Խ���');
  ////'Wide downward diagonal');                                                                                                                                                                      
  cxSetResourceString(@sdxPatternWideUpwardDiagonal,'���϶Խ���');
  ////'Wide upward diagonal');                                                                                                                                                                          
  cxSetResourceString(@sdxPatternLightVertical,'ǳɫ����');
  ////'Light vertical');                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternLightHorizontal,'ǳɫ����');
  ////'Light horizontal');                                                                                                                                                                                   
  cxSetResourceString(@sdxPatternNarrowVertical,'խ����');
  ////'Narrow vertical');                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternNarrowHorizontal,'խ����');
  ////'Narrow horizontal');                                                                                                                                                                                   
  cxSetResourceString(@sdxPatternDarkVertical,'��ɫ����');
  ////'Dark vertical');                                                                                                                                                                                         
  cxSetResourceString(@sdxPatternDarkHorizontal,'��ɫ����');
  ////'Dark horizontal');                                                                                                                                                                                     
  cxSetResourceString(@sdxPatternDashedDownward,'�¶Խ�����');
  ////'Dashed downward');                                                                                                                                                                                   
  cxSetResourceString(@sdxPatternDashedUpward,'�϶Խ�����');
  ////'Dashed upward');                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternDashedVertical,'������');
  ////'Dashed vertical');                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternDashedHorizontal,'������');
  ////'Dashed horizontal');                                                                                                                                                                                   
  cxSetResourceString(@sdxPatternSmallConfetti,'Сֽм');
  ////'Small confetti');                                                                                                                                                                                         
  cxSetResourceString(@sdxPatternLargeConfetti,'��ֽм');
  ////'Large confetti');                                                                                                                                                                                         
  cxSetResourceString(@sdxPatternZigZag,'֮����');
  ////'Zig zag');                                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternWave,'������');
  ////'Wave');                                                                                                                                                                                                            
  cxSetResourceString(@sdxPatternDiagonalBrick,'�Խ�ש��');
  ////'Diagonal brick');                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternHorizantalBrick,'����ש��');
  ////'Horizontal brick');                                                                                                                                                                                   
  cxSetResourceString(@sdxPatternWeave,'��֯��');
  ////'Weave');                                                                                                                                                                                                          
  cxSetResourceString(@sdxPatternPlaid,'�ո���������');
  ////'Plaid');                                                                                                                                                                                                    
  cxSetResourceString(@sdxPatternDivot,'��Ƥ');
  ////'Divot');                                                                                                                                                                                                            
  cxSetResourceString(@sdxPatternDottedGrid,'��������');
  ////'Dottedgrid');                                                                                                                                                                                              
  cxSetResourceString(@sdxPatternDottedDiamond,'��ʽ����');
  ////'Dotted diamond');                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternShingle,'����');
  ////'Shingle');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPatternTrellis,'���');
  ////'Trellis');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPatternSphere,'����');
  ////'Sphere');                                                                                                                                                                                                          
  cxSetResourceString(@sdxPatternSmallGrid,'С����');
  ////'Small grid');                                                                                                                                                                                                 
  cxSetResourceString(@sdxPatternLargeGrid,'������');
  ////'Large grid');                                                                                                                                                                                                 
  cxSetResourceString(@sdxPatternSmallCheckedBoard,'С����');
  ////'Small checked board');                                                                                                                                                                                
  cxSetResourceString(@sdxPatternLargeCheckedBoard,'������');
  ////'Large checked board');                                                                                                                                                                                
  cxSetResourceString(@sdxPatternOutlinedDiamond,'����ʽ����');
  ////'Outlined diamond');                                                                                                                                                                                 
  cxSetResourceString(@sdxPatternSolidDiamond,'ʵ������');
  ////'Solid diamond');                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  { Texture names }                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxTextureNewSprint,'����ֽ');
  ////'Newsprint');                                                                                                                                                                                                  
  cxSetResourceString(@sdxTextureGreenMarble,'��ɫ����ʯ');
  ////'Green marble');                                                                                                                                                                                         
  cxSetResourceString(@sdxTextureBlueTissuePaper,'��ɫɰֽ');
  ////'Blue tissue paper');                                                                                                                                                                                  
  cxSetResourceString(@sdxTexturePapyrus,'ֽɯ��ֽ');
  ////'Papyrus');                                                                                                                                                                                                    
  cxSetResourceString(@sdxTextureWaterDroplets,'ˮ��');
  ////'Water droplets');                                                                                                                                                                                           
  cxSetResourceString(@sdxTextureCork,'��ľ��');
  ////'Cork');                                                                                                                                                                                                            
  cxSetResourceString(@sdxTextureRecycledPaper,'����ֽ');
  ////'Recycled paper');                                                                                                                                                                                         
  cxSetResourceString(@sdxTextureWhiteMarble,'��ɫ����ʯ');
  ////'White marble');                                                                                                                                                                                         
  cxSetResourceString(@sdxTexturePinkMarble,'��ɫɰֽ');
  ////'Pink marble');                                                                                                                                                                                             
  cxSetResourceString(@sdxTextureCanvas,'����');
  ////'Canvas');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTexturePaperBag,'ֽ��');
  ////'Paper bag');                                                                                                                                                                                                     
  cxSetResourceString(@sdxTextureWalnut,'����');
  ////'Walnut');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTextureParchment,'��Ƥֽ');
  ////'Parchment');                                                                                                                                                                                                  
  cxSetResourceString(@sdxTextureBrownMarble,'��ɫ����ʯ');
  ////'Brown marble');                                                                                                                                                                                         
  cxSetResourceString(@sdxTexturePurpleMesh,'��ɫ����');
  ////'Purple mesh');                                                                                                                                                                                             
  cxSetResourceString(@sdxTextureDenim,'б�Ʋ�');
  ////'Denim');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTextureFishFossil,'���໯ʯ');
  ////'Fish fossil');                                                                                                                                                                                             
  cxSetResourceString(@sdxTextureOak,'��ľ');
  ////'Oak');                                                                                                                                                                                                                
  cxSetResourceString(@sdxTextureStationary,'��ֽ');
  ////'Stationary');                                                                                                                                                                                                  
  cxSetResourceString(@sdxTextureGranite,'������');
  ////'Granite');                                                                                                                                                                                                      
  cxSetResourceString(@sdxTextureBouquet,'����');
  ////'Bouquet');                                                                                                                                                                                                        
  cxSetResourceString(@sdxTextureWonenMat,'��֯��');
  ////'Woven mat');                                                                                                                                                                                                   
  cxSetResourceString(@sdxTextureSand,'ɳ̲');
  ////'Sand');                                                                                                                                                                                                              
  cxSetResourceString(@sdxTextureMediumWood,'��ɫľ��');
  ////'Medium wood');                                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxFSPCaption,'ͼ��Ԥ��');
  ////'Picture Preview');                                                                                                                                                                                                
  cxSetResourceString(@sdxWidth,'���');
  ////'Width');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxHeight,'�߶�');
  ////'Height');                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                          
  { Brush Dialog }                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxBrushDlgCaption,'��������');
  ////'Brush properties');                                                                                                                                                                                          
  cxSetResourceString(@sdxStyle,'��ʽ:');
  ////'&Style:');                                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  { Enter New File Name dialog }                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxENFNCaption,'ѡ�����ļ�����');
  ////'Choose New File Name');                                                                                                                                                                                    
  cxSetResourceString(@sdxEnterNewFileName,'�������ļ�����');
  ////'Enter New File Name');                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  { Define styles dialog }                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxDefinePrintStylesCaption,'�����ӡ��ʽ');
  ////'Define Print Styles');                                                                                                                                                                          
  cxSetResourceString(@sdxDefinePrintStylesTitle,'��ӡ��ʽ(&S)');
  ////'Print &Styles');                                                                                                                                                                                  
  cxSetResourceString(@sdxDefinePrintStylesWarningDelete,'ȷ��Ҫɾ�� "%s" ��?');
  ////'Do you want to delete "%s" ?');                                                                                                                                                    
  cxSetResourceString(@sdxDefinePrintStylesWarningClear,'Ҫɾ�����з�������ʽ��?');
  ////'Do you want to delete all not built-in styles ?');                                                                                                                              
  cxSetResourceString(@sdxClear,'���(&L)...');
  ////'C&lear...');                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  { Print device }                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCustomSize,'�Զ����С');
  ////'Custom Size');                                                                                                                                                                                                  
  cxSetResourceString(@sdxDefaultTray,'Ĭ��ֽ��');
  ////'Default Tray');                                                                                                                                                                                                  
  cxSetResourceString(@sdxInvalidPrintDevice,'��ѡ��ӡ����Ч');
  ////'Printer selected is not valid');                                                                                                                                                                    
  cxSetResourceString(@sdxNotPrinting,'��ǰ��ӡ������ӡ');
  ////'Printer is not currently printing');                                                                                                                                                                     
  cxSetResourceString(@sdxPrinting,'���ڴ�ӡ');
  ////'Printing in progress');                                                                                                                                                                                             
  cxSetResourceString(@sdxDeviceOnPort,'%s �� %s');
  ////'%s on %s');                                                                                                                                                                                                     
  cxSetResourceString(@sdxPrinterIndexError,'��ӡ������������Χ');
  ////'Printer index out of range');                                                                                                                                                                    
  cxSetResourceString(@sdxNoDefaultPrintDevice,'û��ѡ��Ĭ�ϴ�ӡ��');
  ////'There is no default printer selected');                                                                                                                                                       
                                                                                                                                                                                                                                                          
  { Edit AutoText Entries Dialog }                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxAutoTextDialogCaption,'�༭�Զ�ͼ�ļ�');
  ////'Edit AutoText Entries');                                                                                                                                                                         
  cxSetResourceString(@sdxEnterAutoTextEntriesHere,'�����Զ�ͼ�ļ���');
  ////' Enter A&utoText Entries Here: ');                                                                                                                                                          
                                                                                                                                                                                                                                                          
  { Print dialog }                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPrintDialogCaption,'��ӡ');
  ////'Print');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintDialogPrinter,'��ӡ��');
  ////' Printer ');                                                                                                                                                                                                
  cxSetResourceString(@sdxPrintDialogName,'����(&N):');
  ////'&Name:');                                                                                                                                                                                                   
  cxSetResourceString(@sdxPrintDialogStatus,'״̬:');
  ////'Status:');                                                                                                                                                                                                    
  cxSetResourceString(@sdxPrintDialogType,'����:');
  ////'Type:');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPrintDialogWhere,'λ��:');
  ////'Where:');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintDialogComment,'��ע:');
  ////'Comment:');                                                                                                                                                                                                  
  cxSetResourceString(@sdxPrintDialogPrintToFile,'��ӡ���ļ�(&F)');
  ////'Print to &File');                                                                                                                                                                               
  cxSetResourceString(@sdxPrintDialogPageRange,' ҳ�淶Χ ');
  ////' Page range ');                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDialogAll,'ȫ��(&A)');
  ////'&All');                                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDialogCurrentPage,'��ǰҳ(&E)');
  ////'Curr&ent Page');                                                                                                                                                                                    
  cxSetResourceString(@sdxPrintDialogSelection,'��ѡ����(&S)');
  ////'&Selection');                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDialogPages,'ҳ�뷶Χ:');
  ////'&Pages:');                                                                                                                                                                                                 
  cxSetResourceString(@sdxPrintDialogRangeLegend,'�����ҳ���/���ö��ŷָ���ҳ�뷶Χ'+#10#13+
  ////'Enter page number and/or page ranges' + #10#13 +                                                                                                                   
    'separated by commas. For example: 1,3,5-12.');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPrintDialogCopies,' ����');
  ////' Copies ');                                                                                                                                                                                                   
  cxSetResourceString(@sdxPrintDialogNumberOfPages,'ҳ��(&U):');
  ////'N&umber of Pages:');                                                                                                                                                                               
  cxSetResourceString(@sdxPrintDialogNumberOfCopies,'����(&C):');
  ////'Number of &Copies:');                                                                                                                                                                             
  cxSetResourceString(@sdxPrintDialogCollateCopies,'��ݴ�ӡ(&T)');
  ////'Colla&te Copies');                                                                                                                                                                              
  cxSetResourceString(@sdxPrintDialogAllPages,'ȫ��');
  ////'All');                                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDialogEvenPages,'ż��ҳ');
  ////'Even');                                                                                                                                                                                                   
  cxSetResourceString(@sdxPrintDialogOddPages,'����ҳ');
  ////'Odd');                                                                                                                                                                                                     
  cxSetResourceString(@sdxPrintDialogPrintStyles,' ��ӡ��ʽ(&Y)');
  ////' Print St&yles ');                                                                                                                                                                               
                                                                                                                                                                                                                                                          
  { PrintToFile Dialog }                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPrintDialogOpenDlgTitle,'ѡ���ļ�����');
  ////'Choose File Name');                                                                                                                                                                              
  cxSetResourceString(@sdxPrintDialogOpenDlgAllFiles,'ȫ���ļ�');
  ////'All Files');                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintDialogOpenDlgPrinterFiles,'��ӡ���ļ�');
  ////'Printer Files');                                                                                                                                                                            
  cxSetResourceString(@sdxPrintDialogPageNumbersOutOfRange,'ҳ�볬����Χ (%d - %d)');
  ////'Page numbers out of range (%d - %d)');                                                                                                                                        
  cxSetResourceString(@sdxPrintDialogInvalidPageRanges,'��Ч��ҳ�뷶Χ');
  ////'Invalid page ranges');                                                                                                                                                                    
  cxSetResourceString(@sdxPrintDialogRequiredPageNumbers,'����ҳ��');
  ////'Enter page numbers');                                                                                                                                                                         
  cxSetResourceString(@sdxPrintDialogNoPrinters,'û�а�װ��ӡ���� Ҫ��װ��ӡ����'+
  ////'No printers are installed. To install a printer, ' +                                                                                                                           
    'point to Settings on the Windows Start menu, click Printers, and then double-click Add Printer. ' +                                                                                                                                                  
    'Follow the instructions in the wizard.');                                                                                                                                                                                                             
  cxSetResourceString(@sdxPrintDialogInPrintingState,'��ӡ�����ڴ�ӡ��'+#10#13+
  ////'Printer is currently printing.' + #10#13 +                                                                                                                                        
    'Please wait.');                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  { Printer State }                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPrintDialogPSPaused,'��ͣ');
  ////'Paused');                                                                                                                                                                                                    
  cxSetResourceString(@sdxPrintDialogPSPendingDeletion,'����ɾ��');
  ////'Pending Deletion');                                                                                                                                                                             
  cxSetResourceString(@sdxPrintDialogPSBusy,'��æ');
  ////'Busy');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPrintDialogPSDoorOpen,'ͨ����');
  ////'Door Open');                                                                                                                                                                                           
  cxSetResourceString(@sdxPrintDialogPSError,'����');
  ////'Error');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintDialogPSInitializing,'��ʼ��');
  ////'Initializing');                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintDialogPSIOActive,'���������Ч');
  ////'IO Active');                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDialogPSManualFeed,'�ֹ���ֽ');
  ////'Manual Feed');                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDialogPSNoToner,'û��ī��');
  ////'No Toner');                                                                                                                                                                                             
  cxSetResourceString(@sdxPrintDialogPSNotAvailable,'������');
  ////'Not Available');                                                                                                                                                                                     
  cxSetResourceString(@sdxPrintDialogPSOFFLine,'�ѻ�');
  ////'Offline');                                                                                                                                                                                                  
  cxSetResourceString(@sdxPrintDialogPSOutOfMemory,'�ڴ����');
  ////'Out of Memory');                                                                                                                                                                                    
  cxSetResourceString(@sdxPrintDialogPSOutBinFull,'�������������');
  ////'Output Bin Full');                                                                                                                                                                             
  cxSetResourceString(@sdxPrintDialogPSPagePunt,'ҳƽ��');
  ////'Page Punt');                                                                                                                                                                                             
  cxSetResourceString(@sdxPrintDialogPSPaperJam,'��ֽ');
  ////'Paper Jam');                                                                                                                                                                                               
  cxSetResourceString(@sdxPrintDialogPSPaperOut,'ֽ������');
  ////'Paper Out');                                                                                                                                                                                           
  cxSetResourceString(@sdxPrintDialogPSPaperProblem,'ֽ������');
  ////'Paper Problem');                                                                                                                                                                                   
  cxSetResourceString(@sdxPrintDialogPSPrinting,'���ڴ�ӡ');
  ////'Printing');                                                                                                                                                                                            
  cxSetResourceString(@sdxPrintDialogPSProcessing,'���ڴ���');
  ////'Processing');                                                                                                                                                                                        
  cxSetResourceString(@sdxPrintDialogPSTonerLow,'ī�۽���');
  ////'Toner Low');                                                                                                                                                                                           
  cxSetResourceString(@sdxPrintDialogPSUserIntervention,'���û�����');
  ////'User Intervention');                                                                                                                                                                         
  cxSetResourceString(@sdxPrintDialogPSWaiting,'���ڵȴ�');
  ////'Waiting');                                                                                                                                                                                              
  cxSetResourceString(@sdxPrintDialogPSWarningUp,'����Ԥ��');
  ////'Warming Up');                                                                                                                                                                                         
  cxSetResourceString(@sdxPrintDialogPSReady,'����');
  ////'Ready');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintDialogPSPrintingAndWaiting,'���ڴ�ӡ��%d document(s)  ��ȴ�');
  ////'Printing: %d document(s) waiting');                                                                                                                                  
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxLeftMargin,'��߾�');
  ////'Left Margin');                                                                                                                                                                                                      
  cxSetResourceString(@sdxTopMargin,'�ϱ߾�');
  ////'Top Margin');                                                                                                                                                                                                        
  cxSetResourceString(@sdxRightMargin,'�ұ߾�');
  ////'Right Margin');                                                                                                                                                                                                    
  cxSetResourceString(@sdxBottomMargin,'�±߾�');
  ////'Bottom Margin');                                                                                                                                                                                                  
  cxSetResourceString(@sdxGutterMargin,'װ����');
  ////'Gutter');                                                                                                                                                                                                         
  cxSetResourceString(@sdxHeaderMargin,'ҳü');
  ////'Header');                                                                                                                                                                                                           
  cxSetResourceString(@sdxFooterMargin,'ҳ��');
  ////'Footer');                                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxUnitsInches,'"');
  ////'"');                                                                                                                                                                                                                    
  cxSetResourceString(@sdxUnitsCentimeters,'����');
  ////'cm');                                                                                                                                                                                                           
  cxSetResourceString(@sdxUnitsMillimeters,'����');
  ////'mm');                                                                                                                                                                                                           
  cxSetResourceString(@sdxUnitsPoints,'��');
  ////'pt');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxUnitsPicas,'����');
  ////'pi');                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxUnitsDefaultName,'Ĭ��');
  ////'Default');                                                                                                                                                                                                      
  cxSetResourceString(@sdxUnitsInchesName,'Ӣ��');
  ////'Inches');                                                                                                                                                                                                        
  cxSetResourceString(@sdxUnitsCentimetersName,'����');
  ////'Centimeters');                                                                                                                                                                                              
  cxSetResourceString(@sdxUnitsMillimetersName,'����');
  ////'Millimeters');                                                                                                                                                                                              
  cxSetResourceString(@sdxUnitsPointsName,'��');
  ////'Points');                                                                                                                                                                                                          
  cxSetResourceString(@sdxUnitsPicasName,'�ɿ�');
  ////'Picas');                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPrintPreview,'��ӡԤ��');
  ////'Print Preview');                                                                                                                                                                                                
  cxSetResourceString(@sdxReportDesignerCaption,'�������');
  ////'Format Report');                                                                                                                                                                                       
  cxSetResourceString(@sdxCompositionDesignerCaption,'�������');
  ////'Composition Editor');                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxComponentNotSupportedByLink,'��� "%s" ������ӡ���֧��');
  ////'Component "%s" not supported by TdxComponentPrinter');                                                                                                                         
  cxSetResourceString(@sdxComponentNotSupported,'��� "%s" ������ӡ���֧��');
  ////'Component "%s" not supported by TdxComponentPrinter');                                                                                                                               
  cxSetResourceString(@sdxPrintDeviceNotReady,'��ӡ����δ��װ����û�о���');
  ////'Printer has not been installed or is not ready');                                                                                                                                      
  cxSetResourceString(@sdxUnableToGenerateReport,'���ܲ�������');
  ////'Unable to generate report');                                                                                                                                                                      
  cxSetResourceString(@sdxPreviewNotRegistered,'û����ע���Ԥ����');
  ////'There is no registered preview form');                                                                                                                                                      
  cxSetResourceString(@sdxComponentNotAssigned,'%s' + #13#10 + 'û��ָ���������');
  ////'%s' + #13#10 + 'Not assigned "Component" property');                                                                                                                            
  cxSetResourceString(@sdxPrintDeviceIsBusy,'��ӡ����æ');
  ////'Printer is busy');                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDeviceError,'��ӡ������!');
  ////'Printer has encountered error !');                                                                                                                                                                       
  cxSetResourceString(@sdxMissingComponent,'ȱ���������');
  ////'Missing "Component" property');                                                                                                                                                                         
  cxSetResourceString(@sdxDataProviderDontPresent,'�ڲ�����û��ָ�����ӵ����');
  ////'There are no Links with Assigned Component in Composition');                                                                                                                       
  cxSetResourceString(@sdxBuildingReport,'������������� %d%%');
  ////'Building report: Completed %d%%');                            // obsolete                                                                                                                        
  cxSetResourceString(@sdxPrintingReport,'���ڴ�ӡ��������� %d ҳ�� ��ESC���ж�...');
  ////'Printing report: Completed %d page(s). Press Esc to cancel'); // obsolete                                                                                                  
  cxSetResourceString(@sdxDefinePrintStylesMenuItem,'�����ӡ��ʽ(&S)...');
  ////'Define Print &Styles...');                                                                                                                                                              
  cxSetResourceString(@sdxAbortPrinting,'Ҫ�жϴ�ӡ��?');
  ////'Abort printing ?');                                                                                                                                                                                       
  cxSetResourceString(@sdxStandardStyle,'��׼��ʽ');
  ////'Standard Style');                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxFontStyleBold,'����');
  ////'Bold');                                                                                                                                                                                                            
  cxSetResourceString(@sdxFontStyleItalic,'б��');
  ////'Italic');                                                                                                                                                                                                        
  cxSetResourceString(@sdxFontStyleUnderline,'�»���');
  ////'Underline');                                                                                                                                                                                                
  cxSetResourceString(@sdxFontStyleStrikeOut,'ɾ����');
  ////'StrikeOut');                                                                                                                                                                                                
  cxSetResourceString(@sdxPt,'��');
  ////'pt.');                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxNoPages,'[û��ҳ��]');
  ////'There are no pages to display');                                                                                                                                                                                   
  cxSetResourceString(@sdxPageWidth,'ҳ��');
  ////'Page Width');                                                                                                                                                                                                          
  cxSetResourceString(@sdxWholePage,'��ҳ');
  ////'Whole Page');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTwoPages,'��ҳ');
  ////'Two Pages');                                                                                                                                                                                                            
  cxSetResourceString(@sdxFourPages,'��ҳ');
  ////'Four Pages');                                                                                                                                                                                                          
  cxSetResourceString(@sdxWidenToSourceWidth,'ԭʼ���');
  ////'Widen to Source Width');                                                                                                                                                                                  
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuBar,'�˵���');
  ////'MenuBar');                                                                                                                                                                                                             
  cxSetResourceString(@sdxStandardBar,'��׼');
  ////'Standard');                                                                                                                                                                                                          
  cxSetResourceString(@sdxHeaderFooterBar,'ҳü��ҳ��');
  ////'Header and Footer');                                                                                                                                                                                       
  cxSetResourceString(@sdxShortcutMenusBar,'��ݲ˵�');
  ////'Shortcut Menus');                                                                                                                                                                                           
  cxSetResourceString(@sdxAutoTextBar,'�Զ�ͼ�ļ�');
  ////'AutoText');                                                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuFile,'�ļ�(&F)');
  ////'&File');                                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuFileDesign,'���(&D)...');
  ////'&Design...');                                                                                                                                                                                              
  cxSetResourceString(@sdxMenuFilePrint,'��ӡ(&P)...');
  ////'&Print...');                                                                                                                                                                                                
  cxSetResourceString(@sdxMenuFilePageSetup,'ҳ������(&U)...');
  ////'Page Set&up...');                                                                                                                                                                                   
  cxSetResourceString(@sdxMenuPrintStyles,'��ӡ��ʽ');
  ////'Print Styles');                                                                                                                                                                                              
  cxSetResourceString(@sdxMenuFileExit,'�ر�(&C)');
  ////'&Close');                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuEdit,'�༭(&E)');
  ////'&Edit');                                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuEditCut,'����(&T)');
  ////'Cu&t');                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuEditCopy,'����(&C)');
  ////'&Copy');                                                                                                                                                                                                        
  cxSetResourceString(@sdxMenuEditPaste,'ճ��(&P)');
  ////'&Paste');                                                                                                                                                                                                      
  cxSetResourceString(@sdxMenuEditDelete,'ɾ��(&D)');
  ////'&Delete');                                                                                                                                                                                                    
  cxSetResourceString(@sdxMenuEditFind,'����(&F)...');
  ////'&Find...');                                                                                                                                                                                                  
  cxSetResourceString(@sdxMenuEditFindNext,'������һ��(&X)');
  ////'Find Ne&xt');                                                                                                                                                                                         
  cxSetResourceString(@sdxMenuEditReplace,'�滻(&R)...');
  ////'&Replace...');                                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuLoad,'����(&L)...');
  ////'&Load...');                                                                                                                                                                                                      
  cxSetResourceString(@sdxMenuPreview,'Ԥ��(&V)...');
  ////'Pre&view...');                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuInsert,'����(&I)');
  ////'&Insert');                                                                                                                                                                                                        
  cxSetResourceString(@sdxMenuInsertAutoText,'�Զ�ͼ�ļ�(&A)');
  ////'&AutoText');                                                                                                                                                                                        
  cxSetResourceString(@sdxMenuInsertEditAutoTextEntries,'�Զ�ͼ�ļ�(&X)...');
  ////'AutoTe&xt...');                                                                                                                                                                       
  cxSetResourceString(@sdxMenuInsertAutoTextEntries,'�Զ�ͼ�ļ��б�');
  ////'List of AutoText Entries');                                                                                                                                                                  
  cxSetResourceString(@sdxMenuInsertAutoTextEntriesSubItem,'�����Զ�ͼ�ļ�(&S)');
  ////'In&sert AutoText');                                                                                                                                                               
  cxSetResourceString(@sdxMenuInsertPageNumber,'ҳ��(&P)');
  ////'&Page Number');                                                                                                                                                                                         
  cxSetResourceString(@sdxMenuInsertTotalPages,'ҳ��(&N)');
  ////'&Number of Pages');                                                                                                                                                                                     
  cxSetResourceString(@sdxMenuInsertPageOfPages,'ҳ��ҳ��(&G)');
  ////'Pa&ge Number of Pages');                                                                                                                                                                           
  cxSetResourceString(@sdxMenuInsertDateTime,'���ں�ʱ��');
  ////'Date and Time');                                                                                                                                                                                        
  cxSetResourceString(@sdxMenuInsertDate,'����(&D)');
  ////'&Date');                                                                                                                                                                                                      
  cxSetResourceString(@sdxMenuInsertTime,'ʱ��(&T)');
  ////'&Time');                                                                                                                                                                                                      
  cxSetResourceString(@sdxMenuInsertUserName,'�û�����(&U)');
  ////'&User Name');                                                                                                                                                                                         
  cxSetResourceString(@sdxMenuInsertMachineName,'��������(&M)');
  ////'&Machine Name');                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuView,'��ͼ(&V)');
  ////'&View');                                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuViewMargins,'ҳ�߾�(&M)');
  ////'&Margins');                                                                                                                                                                                                
  cxSetResourceString(@sdxMenuViewFlatToolBarButtons,'ƽ�湤������ť');
  ////'&Flat ToolBar Buttons');                                                                                                                                                                    
  cxSetResourceString(@sdxMenuViewLargeToolBarButtons,'�󹤾�����ť');
  ////'&Large ToolBar Buttons');                                                                                                                                                                    
  cxSetResourceString(@sdxMenuViewMarginsStatusBar,'ҳ�߾���');
  ////'M&argins Bar');                                                                                                                                                                                     
  cxSetResourceString(@sdxMenuViewPagesStatusBar,'״̬��');
  ////'&Status Bar');                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuViewToolBars,'������');
  ////'&Toolbars');                                                                                                                                                                                                  
  cxSetResourceString(@sdxMenuViewPagesHeaders,'ҳü');
  ////'Page &Headers');                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuViewPagesFooters,'ҳ��');
  ////'Page Foote&rs');                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuViewSwitchToLeftPart,'�л�����');
  ////'Switch to Left Part');                                                                                                                                                                            
  cxSetResourceString(@sdxMenuViewSwitchToRightPart,'�л����Ҳ�');
  ////'Switch to Right Part');                                                                                                                                                                          
  cxSetResourceString(@sdxMenuViewSwitchToCenterPart,'�л����в�');
  ////'Switch to Center Part');                                                                                                                                                                        
  cxSetResourceString(@sdxMenuViewHFSwitchHeaderFooter,'��ʾҳü/ҳ��(&S)');
  ////'&Show Header/Footer');                                                                                                                                                                 
  cxSetResourceString(@sdxMenuViewHFClose,'�ر�(&C)');
  ////'&Close');                                                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuZoom,'����(&Z)');
  ////'&Zoom');                                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuZoomPercent100,'�ٷ�&100');
  ////'Percent &100');                                                                                                                                                                                           
  cxSetResourceString(@sdxMenuZoomPageWidth,'ҳ��(&W)');
  ////'Page &Width');                                                                                                                                                                                             
  cxSetResourceString(@sdxMenuZoomWholePage,'��ҳ(&H)');
  ////'W&hole Page');                                                                                                                                                                                             
  cxSetResourceString(@sdxMenuZoomTwoPages,'��ҳ(&T)');
  ////'&Two Pages');                                                                                                                                                                                               
  cxSetResourceString(@sdxMenuZoomFourPages,'��ҳ(&F)');
  ////'&Four Pages');                                                                                                                                                                                             
  cxSetResourceString(@sdxMenuZoomMultiplyPages,'��ҳ(&M)');
  ////'&Multiple Pages');                                                                                                                                                                                     
  cxSetResourceString(@sdxMenuZoomWidenToSourceWidth,'��չ��ԭʼ���');
  ////'Widen To S&ource Width');                                                                                                                                                                   
  cxSetResourceString(@sdxMenuZoomSetup,'����(&S)...');
  ////'&Setup...');                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuPages,'ҳ��(&P)');
  ////'&Pages');                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuGotoPage,'ת��(&G)');
  ////'&Go');                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuGotoPageFirst,'��ҳ(&F)');
  ////'&First Page');                                                                                                                                                                                             
  cxSetResourceString(@sdxMenuGotoPagePrev,'ǰһҳ(&P)');
  ////'&Previous Page');                                                                                                                                                                                         
  cxSetResourceString(@sdxMenuGotoPageNext,'��һҳ(&N)');
  ////'&Next Page');                                                                                                                                                                                             
  cxSetResourceString(@sdxMenuGotoPageLast,'βҳ(&L)');
  ////'&Last Page');                                                                                                                                                                                               
  cxSetResourceString(@sdxMenuActivePage,'��ǰҳ(&A):');
  ////'&Active Page:');                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuFormat,'��ʽ(&O)');
  ////'F&ormat');                                                                                                                                                                                                        
  cxSetResourceString(@sdxMenuFormatHeaderAndFooter,'ҳü��ҳ��');
  ////'&Header and Footer');                                                                                                                                                                            
  cxSetResourceString(@sdxMenuFormatAutoTextEntries,'�Զ�ͼ�ļ�(&A)...');
  ////'&Auto Text Entries...');                                                                                                                                                                  
  cxSetResourceString(@sdxMenuFormatDateTime,'���ں�ʱ��(&T)...');
  ////'Date And &Time...');                                                                                                                                                                             
  cxSetResourceString(@sdxMenuFormatPageNumbering,'ҳ��(&N)...');
  ////'Page &Numbering...');                                                                                                                                                                             
  cxSetResourceString(@sdxMenuFormatPageBackground,'����(&K)...');
  ////'Bac&kground...');                                                                                                                                                                                
  cxSetResourceString(@sdxMenuFormatShrinkToPage,'��С�ʺ�ҳ��(&F)');
  ////'&Fit to Page');                                                                                                                                                                               
  cxSetResourceString(@sdxMenuShowEmptyPages,'��ʾ�հ�ҳ(&E)');
  ////'Show &Empty Pages');                                                                                                                                                                                
  cxSetResourceString(@sdxMenuFormatHFBackground,'ҳü/ҳ�ű���...');
  ////'Header/Footer Background...');                                                                                                                                                                
  cxSetResourceString(@sdxMenuFormatHFClear,'����ı�');
  ////'Clear Text');                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuTools,'����(&T)');
  ////'&Tools');                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuToolsCustomize,'�Զ���(&C)...');
  ////'&Customize...');                                                                                                                                                                                     
  cxSetResourceString(@sdxMenuToolsOptions,'ѡ��(&O)...');
  ////'&Options...');                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuHelp,'����(&H)');
  ////'&Help');                                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuHelpTopics,'��������(&T)...');
  ////'Help &Topics...');                                                                                                                                                                                     
  cxSetResourceString(@sdxMenuHelpAbout,'����(&A)...');
  ////'&About...');                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuShortcutPreview,'Ԥ��');
  ////'Preview');                                                                                                                                                                                                   
  cxSetResourceString(@sdxMenuShortcutAutoText,'�Զ�ͼ�ļ�');
  ////'AutoText');                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuBuiltInMenus,'���ò˵�');
  ////'Built-in Menus');                                                                                                                                                                                           
  cxSetResourceString(@sdxMenuShortCutMenus,'��ݲ˵�');
  ////'Shortcut Menus');                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuNewMenu,'�½��˵�');
  ////'New Menu');                                                                                                                                                                                                      
                                                                                                                                                                                                                                                          
  { Hints }                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintFileDesign,'��Ʊ���');
  ////'Design Report');                                                                                                                                                                                              
  cxSetResourceString(@sdxHintFilePrint,'��ӡ');
  ////'Print');                                                                                                                                                                                                           
  cxSetResourceString(@sdxHintFilePrintDialog,'��ӡ�Ի���');
  ////'Print Dialog');                                                                                                                                                                                        
  cxSetResourceString(@sdxHintFilePageSetup,'ҳ������');
  ////'Page Setup');                                                                                                                                                                                              
  cxSetResourceString(@sdxHintFileExit,'�ر�Ԥ��');
  ////'Close Preview');                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintEditFind,'����');
  ////'Find');                                                                                                                                                                                                             
  cxSetResourceString(@sdxHintEditFindNext,'������һ��');
  ////'Find Next');                                                                                                                                                                                              
  cxSetResourceString(@sdxHintEditReplace,'�滻');
  ////'Replace');                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintInsertEditAutoTextEntries,'�༭�Զ�ͼ�ļ�');
  ////'Edit AutoText Entries');                                                                                                                                                                 
  cxSetResourceString(@sdxHintInsertPageNumber,'����ҳ��');
  ////'Insert Page Number');                                                                                                                                                                                   
  cxSetResourceString(@sdxHintInsertTotalPages,'����ҳ��');
  ////'Insert Number of Pages');                                                                                                                                                                               
  cxSetResourceString(@sdxHintInsertPageOfPages,'����ҳ��');
  ////'Insert Page Number of Pages');                                                                                                                                                                         
  cxSetResourceString(@sdxHintInsertDateTime,'�������ں�ʱ��');
  ////'Insert Date and Time');                                                                                                                                                                             
  cxSetResourceString(@sdxHintInsertDate,'��������');
  ////'Insert Date');                                                                                                                                                                                                
  cxSetResourceString(@sdxHintInsertTime,'����ʱ��');
  ////'Insert Time');                                                                                                                                                                                                
  cxSetResourceString(@sdxHintInsertUserName,'�����û�����');
  ////'Insert User Name');                                                                                                                                                                                   
  cxSetResourceString(@sdxHintInsertMachineName,'�����������');
  ////'Insert Machine Name');                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintViewMargins,'�鿴ҳ�߾�');
  ////'View Margins');                                                                                                                                                                                            
  cxSetResourceString(@sdxHintViewLargeButtons,'�鿴��ť');
  ////'View Large Buttons');                                                                                                                                                                                 
  cxSetResourceString(@sdxHintViewMarginsStatusBar,'�鿴ҳ�߾�״̬��');
  ////'View Margins Status Bar');                                                                                                                                                                  
  cxSetResourceString(@sdxHintViewPagesStatusBar,'�鿴ҳ��״̬��');
  ////'View Page Status Bar');                                                                                                                                                                         
  cxSetResourceString(@sdxHintViewPagesHeaders,'�鿴ҳü');
  ////'View Page Header');                                                                                                                                                                                     
  cxSetResourceString(@sdxHintViewPagesFooters,'�鿴ҳ��');
  ////'View Page Footer');                                                                                                                                                                                     
  cxSetResourceString(@sdxHintViewSwitchToLeftPart,'�л�����ߵ�ҳü/ҳ��');
  ////'Switch to Left Header/Footer Part');                                                                                                                                                   
  cxSetResourceString(@sdxHintViewSwitchToRightPart,'�л����ұߵ�ҳü/ҳ��');
  ////'Switch to Right Header/Footer Part');                                                                                                                                                 
  cxSetResourceString(@sdxHintViewSwitchToCenterPart,'�л����м��ҳü/ҳ��');
  ////'Switch to Center Header/Footer Part');                                                                                                                                               
  cxSetResourceString(@sdxHintViewHFSwitchHeaderFooter,'��ҳü��ҳ��֮���л�');
  ////'Switch Between Header and Footer');                                                                                                                                                 
  cxSetResourceString(@sdxHintViewHFClose,'�ر�');
  ////'Close');                                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintViewZoom,'����');
  ////'Zoom');                                                                                                                                                                                                             
  cxSetResourceString(@sdxHintZoomPercent100,'�ٷ�100%');
  ////'Zoom 100%');                                                                                                                                                                                              
  cxSetResourceString(@sdxHintZoomPageWidth,'ҳ��');
  ////'Zoom Page Width');                                                                                                                                                                                             
  cxSetResourceString(@sdxHintZoomWholePage,'��ҳ');
  ////'Whole Page');                                                                                                                                                                                                  
  cxSetResourceString(@sdxHintZoomTwoPages,'��ҳ');
  ////'Two Pages');                                                                                                                                                                                                    
  cxSetResourceString(@sdxHintZoomFourPages,'��ҳ');
  ////'Four Pages');                                                                                                                                                                                                  
  cxSetResourceString(@sdxHintZoomMultiplyPages,'��ҳ');
  ////'Multiple Pages');                                                                                                                                                                                          
  cxSetResourceString(@sdxHintZoomWidenToSourceWidth,'��չ��ԭʼ���');
  ////'Widen To Source Width');                                                                                                                                                                    
  cxSetResourceString(@sdxHintZoomSetup,'�������ű���');
  ////'Setup Zoom Factor');                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintFormatDateTime,'��ʽ�����ں�ʱ��');
  ////'Format Date and Time');                                                                                                                                                                           
  cxSetResourceString(@sdxHintFormatPageNumbering,'��ʽ��ҳ��');
  ////'Format Page Number');                                                                                                                                                                              
  cxSetResourceString(@sdxHintFormatPageBackground,'����');
  ////'Background');                                                                                                                                                                                           
  cxSetResourceString(@sdxHintFormatShrinkToPage,'��С�ʺ�ҳ��');
  ////'Shrink To Page');                                                                                                                                                                                 
  cxSetResourceString(@sdxHintFormatHFBackground,'ҳü/ҳ�ű���');
  ////'Header/Footer Background');                                                                                                                                                                      
  cxSetResourceString(@sdxHintFormatHFClear,'���ҳü/ҳ���ı�');
  ////'Clear Header/Footer Text');                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintGotoPageFirst,'��ҳ');
  ////'First Page');                                                                                                                                                                                                  
  cxSetResourceString(@sdxHintGotoPagePrev,'ǰһҳ');
  ////'Previous Page');                                                                                                                                                                                              
  cxSetResourceString(@sdxHintGotoPageNext,'��һҳ');
  ////'Next Page');                                                                                                                                                                                                  
  cxSetResourceString(@sdxHintGotoPageLast,'βҳ');
  ////'Last Page');                                                                                                                                                                                                    
  cxSetResourceString(@sdxHintActivePage,'��ǰҳ');
  ////'Active Page');                                                                                                                                                                                                  
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintToolsCustomize,'�Զ��幤����');
  ////'Customize Toolbars');                                                                                                                                                                                 
  cxSetResourceString(@sdxHintToolsOptions,'ѡ��');
  ////'Options');                                                                                                                                                                                                      
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintHelpTopics,'��������');
  ////'Help Topics');                                                                                                                                                                                                
  cxSetResourceString(@sdxHintHelpAbout,'����');
  ////'About');                                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPopupMenuLargeButtons,'��ť');
  ////'&Large Buttons');                                                                                                                                                                                        
  cxSetResourceString(@sdxPopupMenuFlatButtons,'ƽ�水ť');
  ////'&Flat Buttons');                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPaperSize,'ֽ�Ŵ�С');
  ////'Paper Size:');                                                                                                                                                                                                     
  cxSetResourceString(@sdxStatus,'״̬');
  ////'Status:');                                                                                                                                                                                                                
  cxSetResourceString(@sdxStatusReady,'����');
  ////'Ready');                                                                                                                                                                                                             
  cxSetResourceString(@sdxStatusPrinting,'���ڴ�ӡ������� %d ҳ');
  ////'Printing. Completed %d page(s)');                                                                                                                                                               
  cxSetResourceString(@sdxStatusGenerateReport,'������������� %d%%');
  ////'Generating Report. Completed %d%%');                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintDoubleClickForChangePaperSize,'˫���ı�ֽ�Ŵ�С');
  ////'Double Click for Change Paper Size');                                                                                                                                              
  cxSetResourceString(@sdxHintDoubleClickForChangeMargins,'˫���ı�ҳ�߾�');
  ////'Double Click for Change Margins');                                                                                                                                                     
                                                                                                                                                                                                                                                          
  { Date&Time Formats Dialog }                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxDTFormatsCaption,'������ʱ��');
  ////'Date and Time');                                                                                                                                                                                          
  cxSetResourceString(@sdxDTFormatsAvailableDateFormats,'��Ч�����ڸ�ʽ:');
  ////'&Available Date Formats:');                                                                                                                                                             
  cxSetResourceString(@sdxDTFormatsAvailableTimeFormats,'��Ч��ʱ���ʽ:');
  ////'Available &Time Formats:');                                                                                                                                                             
  cxSetResourceString(@sdxDTFormatsAutoUpdate,'�Զ�����');
  ////'&Update Automatically');                                                                                                                                                                                 
  cxSetResourceString(@sdxDTFormatsChangeDefaultFormat,                                                                                                                                                                                                                      
    'Do you want to change the default date and time formats to match "%s"  - "%s" ?');                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  { PageNumber Formats Dialog }                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPNFormatsCaption,'ҳ���ʽ');
  ////'Page Number Format');                                                                                                                                                                                       
  cxSetResourceString(@sdxPageNumbering,'ҳ��');
  ////'Page Numbering');                                                                                                                                                                                                  
  cxSetResourceString(@sdxPNFormatsNumberFormat,'���ָ�ʽ(&F):');
  ////'Number &Format:');                                                                                                                                                                                
  cxSetResourceString(@sdxPNFormatsContinueFromPrevious,'��ǰ��(&C)');
  ////'&Continue from Previous Section');                                                                                                                                                           
  cxSetResourceString(@sdxPNFormatsStartAt,'��ʼҳ��:');
  ////'Start &At:');                                                                                                                                                                                              
  cxSetResourceString(@sdxPNFormatsChangeDefaultFormat,                                                                                                                                                                                                                      
    'Do you want to change the default Page numbering format to match "%s" ?');                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  { Zoom Dialog }                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxZoomDlgCaption,'����');
  ////'Zoom');                                                                                                                                                                                                           
  cxSetResourceString(@sdxZoomDlgZoomTo,' ������ ');
  ////' Zoom To ');                                                                                                                                                                                                   
  cxSetResourceString(@sdxZoomDlgPageWidth,'ҳ��(&W)');
  ////'Page &Width');                                                                                                                                                                                              
  cxSetResourceString(@sdxZoomDlgWholePage,'��ҳ(&H)');
  ////'W&hole Page');                                                                                                                                                                                              
  cxSetResourceString(@sdxZoomDlgTwoPages,'��ҳ(&T)');
  ////'&Two Pages');                                                                                                                                                                                                
  cxSetResourceString(@sdxZoomDlgFourPages,'��ҳ(&F)');
  ////'&Four Pages');                                                                                                                                                                                              
  cxSetResourceString(@sdxZoomDlgManyPages,'��ҳ(&M):');
  ////'&Many Pages:');                                                                                                                                                                                            
  cxSetResourceString(@sdxZoomDlgPercent,'����:(&E)');
  ////'P&ercent:');                                                                                                                                                                                                 
  cxSetResourceString(@sdxZoomDlgPreview,'Ԥ��');
  ////' Preview ');                                                                                                                                                                                                      
  cxSetResourceString(@sdxZoomDlgFontPreview,' 12pt Times New Roman ');
  ////' 12pt Times New Roman ');                                                                                                                                                                   
  cxSetResourceString(@sdxZoomDlgFontPreviewString,'xypxy@163.net');
  ////'AaBbCcDdEeXxYyZz');                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  { Select page X x Y }                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPages,'ҳ');
  ////'Pages');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxCancel,'ȡ��');
  ////'Cancel');                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                          
  { preferences dialog }                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPreferenceDlgCaption,'ѡ��');
  ////'Options');                                                                                                                                                                                                  
  cxSetResourceString(@sdxPreferenceDlgTab1,'����(&G)');
  ////'&General');                                                                                                                                                                                                
  cxSetResourceString(@sdxPreferenceDlgTab2,'');
  ////'');                                                                                                                                                                                                                
  cxSetResourceString(@sdxPreferenceDlgTab3,'');
  ////'');                                                                                                                                                                                                                
  cxSetResourceString(@sdxPreferenceDlgTab4,'');
  ////'');                                                                                                                                                                                                                
  cxSetResourceString(@sdxPreferenceDlgTab5,'');
  ////'');                                                                                                                                                                                                                
  cxSetResourceString(@sdxPreferenceDlgTab6,'');
  ////'');                                                                                                                                                                                                                
  cxSetResourceString(@sdxPreferenceDlgTab7,'');
  ////'');                                                                                                                                                                                                                
  cxSetResourceString(@sdxPreferenceDlgTab8,'');
  ////'');                                                                                                                                                                                                                
  cxSetResourceString(@sdxPreferenceDlgTab9,'');
  ////'');                                                                                                                                                                                                                
  cxSetResourceString(@sdxPreferenceDlgTab10,'');
  ////'');                                                                                                                                                                                                               
  cxSetResourceString(@sdxPreferenceDlgShow,'��ʾ(&S)');
  ////' &Show ');                                                                                                                                                                                                 
  cxSetResourceString(@sdxPreferenceDlgMargins,'ҳ�߾�(&M)');
  ////'&Margins ');                                                                                                                                                                                          
  cxSetResourceString(@sdxPreferenceDlgMarginsHints,'ҳ�߾���ʾ(&H)');
  ////'Margins &Hints');                                                                                                                                                                            
  cxSetResourceString(@sdxPreferenceDlgMargingWhileDragging,'����ҷʱ��ʾҳ�߾���ʾ(&D)');
  ////'Margins Hints While &Dragging');                                                                                                                                         
  cxSetResourceString(@sdxPreferenceDlgLargeBtns,'�󹤾�����ť(&L)');
  ////'&Large Toolbar Buttons');                                                                                                                                                                     
  cxSetResourceString(@sdxPreferenceDlgFlatBtns,'ƽ�湤������ť(&F)');
  ////'&Flat Toolbar Buttons');                                                                                                                                                                     
  cxSetResourceString(@sdxPreferenceDlgMarginsColor,'ҳ�߾���ɫ(&C):');
  ////'Margins &Color:');                                                                                                                                                                          
  cxSetResourceString(@sdxPreferenceDlgMeasurementUnits,'������λ(&U):');
  ////'Measurement &Units:');                                                                                                                                                                    
  cxSetResourceString(@sdxPreferenceDlgSaveForRunTimeToo,'��������(&R)');
  ////'Save for &RunTime too');                                                                                                                                                                  
  cxSetResourceString(@sdxPreferenceDlgZoomScroll,'�����ֿ�������(&Z)');
  ////'&Zoom on roll with IntelliMouse');                                                                                                                                                       
  cxSetResourceString(@sdxPreferenceDlgZoomStep,'���ű���(&P):');
  ////'Zoom Ste&p:');                                                                                                                                                                                    
                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  { Page Setup }                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCloneStyleCaptionPrefix,'���� (%d) / ');
  ////'Copy (%d) of ');                                                                                                                                                                                 
  cxSetResourceString(@sdxInvalideStyleCaption,'��ʽ���� "%s" �Ѿ����ڡ� ���ṩ��һ�����ơ�');
  ////'The style name "%s" already exists. Please supply another name.');                                                                                                   
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPageSetupCaption,'ҳ������');
  ////'Page Setup');                                                                                                                                                                                               
  cxSetResourceString(@sdxStyleName,'��ʽ����(&N):');
  ////'Style &Name:');                                                                                                                                                                                               
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPage,'ҳ��(&P)');
  ////'&Page');                                                                                                                                                                                                                
  cxSetResourceString(@sdxMargins,'ҳ�߾�(&M)');
  ////'&Margins');                                                                                                                                                                                                        
  cxSetResourceString(@sdxHeaderFooter,'ҳü/ҳ�� (&H)');
  ////'&Header\Footer');                                                                                                                                                                                         
  cxSetResourceString(@sdxScaling,'����(&S)');
  ////'&Scaling');                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPaper,' ֽ�� ');
  ////' Paper ');                                                                                                                                                                                                               
  cxSetResourceString(@sdxPaperType,'ֽ��(&Y)');
  ////'T&ype');                                                                                                                                                                                                           
  cxSetResourceString(@sdxPaperDimension,'�ߴ�(&S)');
  ////'Dimension');                                                                                                                                                                                                  
  cxSetResourceString(@sdxPaperWidth,'���(&W):');
  ////'&Width:');                                                                                                                                                                                                       
  cxSetResourceString(@sdxPaperHeight,'�߶�(&E):');
  ////'H&eight:');                                                                                                                                                                                                     
  cxSetResourceString(@sdxPaperSource,'ֽ����Դ(&U)');
  ////'Paper so&urce');                                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxOrientation,' ����');
  ////' Orientation ');                                                                                                                                                                                                    
  cxSetResourceString(@sdxPortrait,'����(&O)');
  ////'P&ortrait');                                                                                                                                                                                                        
  cxSetResourceString(@sdxLandscape,'����(&L)');
  ////'&Landscape');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintOrder,' ��ӡ����');
  ////' Print Order ');                                                                                                                                                                                                 
  cxSetResourceString(@sdxDownThenOver,'���к���(&D)');
  ////'&Down, then over');                                                                                                                                                                                         
  cxSetResourceString(@sdxOverThenDown,'���к���(&V)');
  ////'O&ver, then down');                                                                                                                                                                                         
  cxSetResourceString(@sdxShading,' ��Ӱ ');
  ////' Shading ');                                                                                                                                                                                                           
  cxSetResourceString(@sdxPrintUsingGrayShading,'ʹ�û�ɫ��Ӱ��ӡ(&G)');
  ////'Print using &gray shading');                                                                                                                                                               
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCenterOnPage,'���з�ʽ');
  ////'Center on page');                                                                                                                                                                                               
  cxSetResourceString(@sdxHorizontally,'ˮƽ(&Z)');
  ////'Hori&zontally');                                                                                                                                                                                                
  cxSetResourceString(@sdxVertically,'��ֱ(&V)');
  ////'&Vertically');                                                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHeader,'ҳü ');
  ////'Header ');                                                                                                                                                                                                               
  cxSetResourceString(@sdxBtnHeaderFont,'����(&F)...');
  ////'&Font...');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnHeaderBackground,'����(&B)');
  ////'&Background');                                                                                                                                                                                           
  cxSetResourceString(@sdxFooter,'ҳ�� ');
  ////'Footer ');                                                                                                                                                                                                               
  cxSetResourceString(@sdxBtnFooterFont,'����(&N)...');
  ////'Fo&nt...');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnFooterBackground,'����(&G)');
  ////'Back&ground');                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxTop,'��(&T):');
  ////'&Top:');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxLeft,'��(&L):');
  ////'&Left:');                                                                                                                                                                                                                
  cxSetResourceString(@sdxRight,'��(&G):');
  ////'Ri&ght:');                                                                                                                                                                                                              
  cxSetResourceString(@sdxBottom,'��(&B):');
  ////'&Bottom:');                                                                                                                                                                                                            
  cxSetResourceString(@sdxHeader2,'ҳü(&E):');
  ////'H&eader:');                                                                                                                                                                                                         
  cxSetResourceString(@sdxFooter2,'ҳ��(&R):');
  ////'Foote&r:');                                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxAlignment,'���뷽ʽ');
  ////'Alignment');                                                                                                                                                                                                       
  cxSetResourceString(@sdxVertAlignment,' ��ֱ����');
  ////' Vertical Alignment ');                                                                                                                                                                                       
  cxSetResourceString(@sdxReverseOnEvenPages,'żҳ�෴(&R)');
  ////'&Reverse on even pages');                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxAdjustTo,'������:');
  ////'&Adjust To:');                                                                                                                                                                                                       
  cxSetResourceString(@sdxFitTo,'�ʺ�:');
  ////'&Fit To:');                                                                                                                                                                                                               
  cxSetResourceString(@sdxPercentOfNormalSize,'% ������С');
  ////'% normal size');                                                                                                                                                                                       
  cxSetResourceString(@sdxPagesWideBy,'ҳ��(&W)');
  ////'page(s) &wide by');                                                                                                                                                                                              
  cxSetResourceString(@sdxTall,'ҳ��(&T)');
  ////'&tall');                                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxOf,'��');
  ////'Of');                                                                                                                                                                                                                           
  cxSetResourceString(@sdxLastPrinted,'�ϴδ�ӡʱ�� ');
  ////'Last Printed ');                                                                                                                                                                                            
  cxSetResourceString(@sdxFileName,'�ļ����� ');
  ////'Filename ');                                                                                                                                                                                                       
  cxSetResourceString(@sdxFileNameAndPath,'�ļ����ƺ�·�� ');
  ////'Filename and path ');                                                                                                                                                                                 
  cxSetResourceString(@sdxPrintedBy,'��ӡ�� ');
  ////'Printed By ');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintedOn,'��ӡ�� ');
  ////'Printed On ');                                                                                                                                                                                                      
  cxSetResourceString(@sdxCreatedBy,'������ ');
  ////'Created By ');                                                                                                                                                                                                      
  cxSetResourceString(@sdxCreatedOn,'������ ');
  ////'Created On ');                                                                                                                                                                                                      
  cxSetResourceString(@sdxConfidential,'����');
  ////'Confidential'); 

  { HF function }
  
  cxSetResourceString(@sdxHFFunctionNameUnknown,'Unknown');
  cxSetResourceString(@sdxHFFunctionNamePageNumber,'Page Number');
  cxSetResourceString(@sdxHFFunctionNameTotalPages,'Total Pages');
  cxSetResourceString(@sdxHFFunctionNamePageOfPages,'Page # of Pages #');
  cxSetResourceString(@sdxHFFunctionNameDateTime,'Date and Time');
  cxSetResourceString(@sdxHFFunctionNameDate,'Date');
  cxSetResourceString(@sdxHFFunctionNameTime,'Time');
  cxSetResourceString(@sdxHFFunctionNameUserName,'User Name');
  cxSetResourceString(@sdxHFFunctionNameMachineName,'Machine Name');

  cxSetResourceString(@sdxHFFunctionHintPageNumber,'Page Number');
  cxSetResourceString(@sdxHFFunctionHintTotalPages,'Total Pages');
  cxSetResourceString(@sdxHFFunctionHintPageOfPages,'Page # of Pages #');
  cxSetResourceString(@sdxHFFunctionHintDateTime,'Date and Time Printed');
  cxSetResourceString(@sdxHFFunctionHintDate,'Date Printed');
  cxSetResourceString(@sdxHFFunctionHintTime,'Time Printed');
  cxSetResourceString(@sdxHFFunctionHintUserName,'User Name');
  cxSetResourceString(@sdxHFFunctionHintMachineName,'Machine Name');

  cxSetResourceString(@sdxHFFunctionTemplatePageNumber,'Page #');
  cxSetResourceString(@sdxHFFunctionTemplateTotalPages,'Total Pages');
  cxSetResourceString(@sdxHFFunctionTemplatePageOfPages,'Page # of Pages #');
  cxSetResourceString(@sdxHFFunctionTemplateDateTime,'Date & Time Printed');
  cxSetResourceString(@sdxHFFunctionTemplateDate,'Date Printed');
  cxSetResourceString(@sdxHFFunctionTemplateTime,'Time Printed');
  cxSetResourceString(@sdxHFFunctionTemplateUserName,'User Name');
  cxSetResourceString(@sdxHFFunctionTemplateMachineName,'Machine Name');

  { Designer strings }
  
  { Months }
  
  cxSetResourceString(@sdxJanuary,'һ��');
  ////'January');                                                                                                                                                                                                               
  cxSetResourceString(@sdxFebruary,'����');
  ////'February');                                                                                                                                                                                                             
  cxSetResourceString(@sdxMarch,'����');
  ////'March');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxApril,'����');
  ////'April');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxMay,'����');
  ////'May');                                                                                                                                                                                                                       
  cxSetResourceString(@sdxJune,'����');
  ////'June');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxJuly,'����');
  ////'July');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxAugust,'����');
  ////'August');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxSeptember,'����');
  ////'September');                                                                                                                                                                                                           
  cxSetResourceString(@sdxOctober,'ʮ��');
  ////'October');                                                                                                                                                                                                               
  cxSetResourceString(@sdxNovember,'ʮһ��');
  ////'November');                                                                                                                                                                                                           
  cxSetResourceString(@sdxDecember,'ʮ����');
  ////'December');                                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxEast,'����');
  ////'East');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxWest,'����');
  ////'West');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxSouth,'�Ϸ�');
  ////'South');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxNorth,'����');
  ////'North');                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxTotal,'�ϼ�');
  ////'Total');                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  { dxFlowChart }                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPlan,'���ͼ');
  ////'Plan');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxSwimmingPool,'��Ӿ��');
  ////'Swimming-pool');                                                                                                                                                                                                  
  cxSetResourceString(@sdxAdministration,'����Ա');
  ////'Administration');                                                                                                                                                                                               
  cxSetResourceString(@sdxPark,'��԰');
  ////'Park');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxCarParking,'ͣ����');
  ////'Car-Parking');                                                                                                                                                                                                      
                                                                                                                                                                                                                                                          
  { dxOrgChart }                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCorporateHeadquarters,'��˾'+#13#10+'�ܲ�');
  ////'Corporate' + #13#10 + 'Headquarters');                                                                                                                                                       
  cxSetResourceString(@sdxSalesAndMarketing,'���۲�'+#13#10+'�г���');
  ////'Sales and' + #13#10 + 'Marketing');                                                                                                                                                          
  cxSetResourceString(@sdxEngineering,'���̼�����');
  ////'Engineering');                                                                                                                                                                                                 
  cxSetResourceString(@sdxFieldOfficeCanada,'�칫��:'+#13#10+'���ô�');
  ////'Field Office:' + #13#10 + 'Canada');                                                                                                                                                        
                                                                                                                                                                                                                                                          
  { dxMasterView }                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxOrderNoCaption,'���');
  ////'OrderNo');                                                                                                                                                                                                        
  cxSetResourceString(@sdxNameCaption,'����');
  ////'Name');                                                                                                                                                                                                              
  cxSetResourceString(@sdxCountCaption,'����');
  ////'Count');                                                                                                                                                                                                            
  cxSetResourceString(@sdxCompanyCaption,'��˾');
  ////'Company');                                                                                                                                                                                                        
  cxSetResourceString(@sdxAddressCaption,'��ַ');
  ////'Address');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPriceCaption,'�۸�');
  ////'Price');                                                                                                                                                                                                            
  cxSetResourceString(@sdxCashCaption,'�ֽ�');
  ////'Cash');                                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxName1,'����');
  ////'Jennie Valentine');                                                                                                                                                                                                        
  cxSetResourceString(@sdxName2,'����');
  ////'Sam Hill');                                                                                                                                                                                                                
  cxSetResourceString(@sdxCompany1,'�������޹�˾');
  ////'Jennie Inc.');                                                                                                                                                                                                  
  cxSetResourceString(@sdxCompany2,'������');
  ////'Daimler-Chrysler AG');                                                                                                                                                                                              
  cxSetResourceString(@sdxAddress1,'123 Home Lane');
  ////'123 Home Lane');                                                                                                                                                                                               
  cxSetResourceString(@sdxAddress2,'9333 Holmes Dr.');
  ////'9333 Holmes Dr.');                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  { dxTreeList }                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCountIs,'������%d');
  ////'Count is: %d');                                                                                                                                                                                                      
  cxSetResourceString(@sdxRegular,'����');
  ////'Regular');                                                                                                                                                                                                               
  cxSetResourceString(@sdxIrregular,'������');
  ////'Irregular');                                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxTLBand,'��Ŀ����');
  ////'Item Data');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTLColumnName,'����');
  ////'Name');                                                                                                                                                                                                             
  cxSetResourceString(@sdxTLColumnAxisymmetric,'��Գ�');
  ////'Axisymmetric');                                                                                                                                                                                           
  cxSetResourceString(@sdxTLColumnItemShape,'��״');
  ////'Shape');                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxItemShapeAsText,'(ͼ��)');
  ////'(Graphic)');                                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxItem1Name,'׶����');
  ////'Cylinder');                                                                                                                                                                                                          
  cxSetResourceString(@sdxItem2Name,'Բ����');
  ////'Cone');                                                                                                                                                                                                              
  cxSetResourceString(@sdxItem3Name,'��׶');
  ////'Pyramid');                                                                                                                                                                                                             
  cxSetResourceString(@sdxItem4Name,'����');
  ////'Box');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxItem5Name,'���ɱ���');
  ////'Free Surface');                                                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxItem1Description,'');
  ////'');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxItem2Description,'��ԳƼ���ͼ��');
  ////'Axisymmetric geometry figure');                                                                                                                                                                       
  cxSetResourceString(@sdxItem3Description,'��ԳƼ���ͼ��');
  ////'Axisymmetric geometry figure');                                                                                                                                                                       
  cxSetResourceString(@sdxItem4Description,'��Ǽ���ͼ��');
  ////'Acute-angled geometry figure');                                                                                                                                                                         
  cxSetResourceString(@sdxItem5Description,'');
  ////'');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxItem6Description,'');
  ////'');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxItem7Description,'��ͻ������');
  ////'Simple extrusion surface');                                                                                                                                                                             
                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  { PS 2.3 }                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  { Patterns common }                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPatternIsNotRegistered,'ģʽ "%s" û��ע��');
  ////'Pattern "%s" is not registered');                                                                                                                                                           
                                                                                                                                                                                                                                                          
  { Excel edge patterns }                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxSolidEdgePattern,'ʵ��');
  ////'Solid');                                                                                                                                                                                                        
  cxSetResourceString(@sdxThinSolidEdgePattern,'ϸʵ��');
  ////'Medium Solid');                                                                                                                                                                                           
  cxSetResourceString(@sdxMediumSolidEdgePattern,'��ʵ��');
  ////'Medium Solid');                                                                                                                                                                                         
  cxSetResourceString(@sdxThickSolidEdgePattern,'��ʵ��');
  ////'Thick Solid');                                                                                                                                                                                           
  cxSetResourceString(@sdxDottedEdgePattern,'Բ��');
  ////'Dotted');                                                                                                                                                                                                      
  cxSetResourceString(@sdxDashedEdgePattern,'�̻���');
  ////'Dashed');                                                                                                                                                                                                    
  cxSetResourceString(@sdxDashDotDotEdgePattern,'�̻���-��-��');
  ////'Dash Dot Dot');                                                                                                                                                                                    
  cxSetResourceString(@sdxDashDotEdgePattern,'�̻���-��');
  ////'Dash Dot');                                                                                                                                                                                              
  cxSetResourceString(@sdxSlantedDashDotEdgePattern,'б�̻���-��');
  ////'Slanted Dash Dot');                                                                                                                                                                             
  cxSetResourceString(@sdxMediumDashDotDotEdgePattern,'�еȶ̻���-��-��');
  ////'Medium Dash Dot Dot');                                                                                                                                                                   
  cxSetResourceString(@sdxHairEdgePattern,'˿״');
  ////'Hair');                                                                                                                                                                                                          
  cxSetResourceString(@sdxMediumDashDotEdgePattern,'�еȶ̻���-��');
  ////'Medium Dash Dot');                                                                                                                                                                             
  cxSetResourceString(@sdxMediumDashedEdgePattern,'�еȶ̻���');
  ////'Medium Dashed');                                                                                                                                                                                   
  cxSetResourceString(@sdxDoubleLineEdgePattern,'˫��');
  ////'Double Line');                                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  { Excel fill patterns names}                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxSolidFillPattern,'ԭɫ');
  ////'Solid');                                                                                                                                                                                                        
  cxSetResourceString(@sdxGray75FillPattern,'75% ��ɫ');
  ////'75% Gray');                                                                                                                                                                                                
  cxSetResourceString(@sdxGray50FillPattern,'50% ��ɫ');
  ////'50% Gray');                                                                                                                                                                                                
  cxSetResourceString(@sdxGray25FillPattern,'25% ��ɫ');
  ////'25% Gray');                                                                                                                                                                                                
  cxSetResourceString(@sdxGray125FillPattern,'12.5% ��ɫ');
  ////'12.5% Gray');                                                                                                                                                                                           
  cxSetResourceString(@sdxGray625FillPattern,'6.25% ��ɫ');
  ////'6.25% Gray');                                                                                                                                                                                           
  cxSetResourceString(@sdxHorizontalStripeFillPattern,'ˮƽ����');
  ////'Horizontal Stripe');                                                                                                                                                                             
  cxSetResourceString(@sdxVerticalStripeFillPattern,'��ֱ����');
  ////'Vertical Stripe');                                                                                                                                                                                 
  cxSetResourceString(@sdxReverseDiagonalStripeFillPattern,'��Խ�������');
  ////'Reverse Diagonal Stripe');                                                                                                                                                              
  cxSetResourceString(@sdxDiagonalStripeFillPattern,'�Խ�������');
  ////'Diagonal Stripe');                                                                                                                                                                               
  cxSetResourceString(@sdxDiagonalCrossHatchFillPattern,'�Խ���������');
  ////'Diagonal Cross Hatch');                                                                                                                                                                    
  cxSetResourceString(@sdxThickCrossHatchFillPattern,'�ֶԽ���������');
  ////'Thick Cross Hatch');                                                                                                                                                                        
  cxSetResourceString(@sdxThinHorizontalStripeFillPattern,'ϸˮƽ����');
  ////'Thin Horizontal Stripe');                                                                                                                                                                  
  cxSetResourceString(@sdxThinVerticalStripeFillPattern,'ϸ��ֱ����');
  ////'Thin Vertical Stripe');                                                                                                                                                                      
  cxSetResourceString(@sdxThinReverseDiagonalStripeFillPattern,'Thin Reverse Diagonal Stripe');                                                                                                                                                                               
  cxSetResourceString(@sdxThinDiagonalStripeFillPattern,'ϸ�Խ�������');
  ////'Thin Diagonal Stripe');                                                                                                                                                                    
  cxSetResourceString(@sdxThinHorizontalCrossHatchFillPattern,'ϸˮƽ������');
  ////'Thin Horizontal Cross Hatch');                                                                                                                                                       
  cxSetResourceString(@sdxThinDiagonalCrossHatchFillPattern,'ϸ�Խ���������');
  ////'Thin Diagonal Cross Hatch');                                                                                                                                                         
                                                                                                                                                                                                                                                          
  { cxSpreadSheet }                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxShowRowAndColumnHeadings,'�к��б���(&R)');
  ////'&Row and Column Headings');                                                                                                                                                                   
  cxSetResourceString(@sdxShowGridLines,'������');
  ////'GridLines');                                                                                                                                                                                                     
  cxSetResourceString(@sdxSuppressSourceFormats,'��ֹԴ��ʽ(&S)');
  ////'&Suppress Source Formats');                                                                                                                                                                      
  cxSetResourceString(@sdxRepeatHeaderRowAtTop,'�ڶ����ظ�������');
  ////'Repeat Header Row at Top');                                                                                                                                                                     
  cxSetResourceString(@sdxDataToPrintDoesNotExist,                                                                                                                                                                                                                           
    'Cannot activate ReportLink because PrintingSystem did not find anything to print.');                                                                                                                                                                  
                                                                                                                                                                                                                                                          
  { Designer strings }                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  { Short names of month }                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxJanuaryShort,'һ��');
  ////'Jan');                                                                                                                                                                                                              
  cxSetResourceString(@sdxFebruaryShort,'����');
  ////'Feb');                                                                                                                                                                                                             
  cxSetResourceString(@sdxMarchShort,'����');
  ////'March');                                                                                                                                                                                                              
  cxSetResourceString(@sdxAprilShort,'����');
  ////'April');                                                                                                                                                                                                              
  cxSetResourceString(@sdxMayShort,'����');
  ////'May');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxJuneShort,'����');
  ////'June');                                                                                                                                                                                                                
  cxSetResourceString(@sdxJulyShort,'����');
  ////'July');                                                                                                                                                                                                                
  cxSetResourceString(@sdxAugustShort,'����');
  ////'Aug');                                                                                                                                                                                                               
  cxSetResourceString(@sdxSeptemberShort,'����');
  ////'Sept');                                                                                                                                                                                                           
  cxSetResourceString(@sdxOctoberShort,'ʮ��');
  ////'Oct');                                                                                                                                                                                                              
  cxSetResourceString(@sdxNovemberShort,'ʮһ��');
  ////'Nov');                                                                                                                                                                                                           
  cxSetResourceString(@sdxDecemberShort,'ʮ����');
  ////'Dec');                                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  { TreeView }                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxTechnicalDepartment,'��������');
  ////'Technical Department');                                                                                                                                                                                  
  cxSetResourceString(@sdxSoftwareDepartment,'�������');
  ////'Software Department');                                                                                                                                                                                    
  cxSetResourceString(@sdxSystemProgrammers,'ϵͳ����Ա');
  ////'Core Developers');                                                                                                                                                                                       
  cxSetResourceString(@sdxEndUserProgrammers,'�ն��û�����Ա');
  ////'GUI Developers');                                                                                                                                                                                   
  cxSetResourceString(@sdxBetaTesters,'����Ա');
  ////'Beta Testers');                                                                                                                                                                                                    
  cxSetResourceString(@sdxHumanResourceDepartment,'������Դ����');
  ////'Human Resource Department');                                                                                                                                                                     
                                                                                                                                                                                                                                                          
  { misc. }                                                                                                                                                                                                                                               
  cxSetResourceString(@sdxTreeLines,'����');
  ////'&TreeLines');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTreeLinesColor,'������ɫ:');
  ////'T&ree Line Color:');                                                                                                                                                                                         
  cxSetResourceString(@sdxExpandButtons,'չ����ť');
  ////'E&xpand Buttons');                                                                                                                                                                                             
  cxSetResourceString(@sdxCheckMarks,'�����');
  ////'Check Marks');                                                                                                                                                                                                    
  cxSetResourceString(@sdxTreeEffects,'��Ч��');
  ////'Tree Effects');                                                                                                                                                                                                    
  cxSetResourceString(@sdxAppearance,'���');
  ////'Appearance');                                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  { Designer previews }                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  { Localize if you want (they are used inside FormatReport dialog -> ReportPreview) }                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCarLevelCaption,'����');
  ////'Cars');                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxManufacturerBandCaption,'Manufacturer Data');                                                                                                                                                                                                       
  cxSetResourceString(@sdxModelBandCaption,'��������');
  ////'Car Data');                                                                                                                                                                                                 
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxManufacturerNameColumnCaption,'Name');                                                                                                                                                                                                              
  cxSetResourceString(@sdxManufacturerLogoColumnCaption,'Logo');                                                                                                                                                                                                              
  cxSetResourceString(@sdxManufacturerCountryColumnCaption,'Country');                                                                                                                                                                                                        
  cxSetResourceString(@sdxCarModelColumnCaption,'ģ��');
  ////'Model');                                                                                                                                                                                                   
  cxSetResourceString(@sdxCarIsSUVColumnCaption,'SUV');
  ////'SUV');                                                                                                                                                                                                      
  cxSetResourceString(@sdxCarPhotoColumnCaption,'��Ƭ');
  ////'Photo');                                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCarManufacturerName1,'BMW');                                                                                                                                                                                                                        
  cxSetResourceString(@sdxCarManufacturerName2,'Ford');                                                                                                                                                                                                                       
  cxSetResourceString(@sdxCarManufacturerName3,'Audi');                                                                                                                                                                                                                       
  cxSetResourceString(@sdxCarManufacturerName4,'Land Rover');                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCarManufacturerCountry1,'Germany');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxCarManufacturerCountry2,'United States');                                                                                                                                                                                                           
  cxSetResourceString(@sdxCarManufacturerCountry3,'Germany');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxCarManufacturerCountry4,'United Kingdom');                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCarModel1,'X5 4WD');
  ////'X5 4.6is');                                                                                                                                                                                                          
  cxSetResourceString(@sdxCarModel2,'����');
  ////'Excursion');                                                                                                                                                                                                           
  cxSetResourceString(@sdxCarModel3,'S8 Quattro');
  ////'S8 Quattro');                                                                                                                                                                                                    
  cxSetResourceString(@sdxCarModel4,'G4 ��ս');
  ////'G4 Challenge');                                                                                                                                                                                                     
                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxTrue,'��');
  ////'True');                                                                                                                                                                                                                       
  cxSetResourceString(@sdxFalse,'��');
  ////'False');                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                          
  { PS 2.4 }                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  { dxPrnDev.pas }                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxAuto,'�Զ�');
  ////'Auto');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxCustom,'����');
  ////'Custom');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxEnv,'Env');
  ////'Env');                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  { Grid 4 }                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxLookAndFeelFlat,'ƽ��');
  ////'Flat');                                                                                                                                                                                                          
  cxSetResourceString(@sdxLookAndFeelStandard,'��׼');
  ////'Standard');                                                                                                                                                                                                  
  cxSetResourceString(@sdxLookAndFeelUltraFlat,'��ƽ��');
  ////'UltraFlat');                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxViewTab,'��ͼ');
  ////'View');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxBehaviorsTab,'����');
  ////'Behaviors');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPreviewTab,'Ԥ��');
  ////'Preview');                                                                                                                                                                                                            
  cxSetResourceString(@sdxCardsTab,'��Ƭ');
  ////'Cards');                                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxFormatting,'��ʽ');
  ////'Formatting');                                                                                                                                                                                                         
  cxSetResourceString(@sdxLookAndFeel,'���');
  ////'Look and Feel');                                                                                                                                                                                                     
  cxSetResourceString(@sdxLevelCaption,'����');
  ////'&Caption');                                                                                                                                                                                                         
  cxSetResourceString(@sdxFilterBar,'������״̬��');
  ////'&Filter Bar');                                                                                                                                                                                                 
  cxSetResourceString(@sdxRefinements,'����');
  ////'Refinements');                                                                                                                                                                                                       
  cxSetResourceString(@sdxProcessSelection,'����ѡ��(&S)');
  ////'Process &Selection');                                                                                                                                                                                   
  cxSetResourceString(@sdxProcessExactSelection,'����ȷѡ��(&X)');
  ////'Process E&xact Selection');                                                                                                                                                                    
  cxSetResourceString(@sdxExpanding,'����');
  ////'Expanding');                                                                                                                                                                                                           
  cxSetResourceString(@sdxGroups,'��(&G)');
  ////'&Groups');                                                                                                                                                                                                              
  cxSetResourceString(@sdxDetails,'ϸ��(&D)');
  ////'&Details');                                                                                                                                                                                                          
  cxSetResourceString(@sdxStartFromActiveDetails,'�ӵ�ǰϸ�ڿ�ʼ');
  ////'Start from Active Details');                                                                                                                                                                    
  cxSetResourceString(@sdxOnlyActiveDetails,'������ǰϸ��');
  ////'Only Active Details');                                                                                                                                                                                 
  cxSetResourceString(@sdxVisible,'�ɼ�(&V)');
  ////'&Visible');                                                                                                                                                                                                          
  cxSetResourceString(@sdxPreviewAutoHeight,'�Զ��߶�(&U)');
  ////'A&uto Height');                                                                                                                                                                                        
  cxSetResourceString(@sdxPreviewMaxLineCount,'����м���(&M)�� ');
  ////'&Max Line Count: ');                                                                                                                                                                            
  cxSetResourceString(@sdxSizes,'��С');
  ////'Sizes');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxKeepSameWidth,'����ͬ�����(&K)');
  ////'&Keep Same Width');                                                                                                                                                                                    
  cxSetResourceString(@sdxKeepSameHeight,'����ͬ���߶�(&H)');
  ////'Keep Same &Height');                                                                                                                                                                                  
  cxSetResourceString(@sdxFraming,'���');
  ////'Framing');                                                                                                                                                                                                               
  cxSetResourceString(@sdxSpacing,'���');
  ////'Spacing');                                                                                                                                                                                                               
  cxSetResourceString(@sdxShadow,'��Ӱ');
  ////'Shadow');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxDepth,'Ũ��(&D):');
  ////'&Depth:');                                                                                                                                                                                                            
  cxSetResourceString(@sdxPosition,'λ��(&P)');
  ////'&Position');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPositioning,'λ��');
  ////'Positioning');                                                                                                                                                                                                       
  cxSetResourceString(@sdxHorizontal,'ˮƽ(&O):');
  ////'H&orizontal:');                                                                                                                                                                                                  
  cxSetResourceString(@sdxVertical,'��ֱ(&E):');
  ////'V&ertical:');                                                                                                                                                                                                      
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxSummaryFormat,'����,0');
  ////'Count,0');                                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCannotUseOnEveryPageMode,'����ʹ����ÿҳ��ʽ'+#13#10+
  ////'Cannot Use OnEveryPage Mode'+ #13#10 +                                                                                                                                            
    #13#10 +                                                                                                                                                                                                                                              
    'You should or(and)' + #13#10 +                                                                                                                                                                                                                       
    '  - Collapse all Master Records' + #13#10 +                                                                                                                                                                                                          
    '  - Toggle "Unwrap" Option off on "Behaviors" Tab');                                                                                                                                                                                                  
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxIncorrectBandHeadersState,'����ʹ�ô�����ͷ��ÿһҳ��ʽ'+#13#10+
  ////'Cannot Use BandHeaders OnEveryPage Mode' + #13#10 +                                                                                                                    
    #13#10 +                                                                                                                                                                                                                                              
    'You should either:' + #13#10 +                                                                                                                                                                                                                       
    '  - Set Caption OnEveryPage Option On' + #13#10 +                                                                                                                                                                                                    
    '  - Set Caption Visible Option Off');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxIncorrectHeadersState,'����ʹ�ñ�ͷ��ÿһҳ��ʽ'+#13#10+
  ////'Cannot Use Headers OnEveryPage Mode' + #13#10 +                                                                                                                                
    #13#10 +                                                                                                                                                                                                                                              
    'You should either:' + #13#10 +                                                                                                                                                                                                                       
    '  - Set Caption and Band OnEveryPage Option On' + #13#10 +                                                                                                                                                                                           
    '  - Set Caption and Band Visible Option Off');                                                                                                                                                                                                        
  cxSetResourceString(@sdxIncorrectFootersState,'����ʹ��ҳ����ÿһҳ��ʽ'+#13#10+
  ////'Cannot Use Footers OnEveryPage Mode' + #13#10 +                                                                                                                                
    #13#10 +                                                                                                                                                                                                                                              
    'You should either:' + #13#10 +                                                                                                                                                                                                                       
    '  - Set FilterBar OnEveryPage Option On' + #13#10 +                                                                                                                                                                                                  
    '  - Set FilterBar Visible Option Off');

  cxSetResourceString(@sdxCharts,'ͼ��');
  //sdl//'Charts'
                                                                                                                                                                                                                                                          
  { PS 3 }                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxTPicture,'TPicture');                                                                                                                                                                                                                               
  cxSetResourceString(@sdxCopy,'&Copy');                                                                                                                                                                                                                                      
  cxSetResourceString(@sdxSave,'&Save...');                                                                                                                                                                                                                                   
  cxSetResourceString(@sdxBaseStyle,'Base Style');                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxComponentAlreadyExists,'Component named "%s" already exists');                                                                                                                                                                                      
  cxSetResourceString(@sdxInvalidComponentName,'"%s" is not a valid component name');
  
  { shapes } 
 
  cxSetResourceString(@sdxRectangle,'Rectangle');
  cxSetResourceString(@sdxSquare,'Square');
  cxSetResourceString(@sdxEllipse,'Ellipse');
  cxSetResourceString(@sdxCircle,'Circle');
  cxSetResourceString(@sdxRoundRect,'RoundRect');
  cxSetResourceString(@sdxRoundSquare,'RoundSquare');

  { standard pattern names}
    
  cxSetResourceString(@sdxHorizontalFillPattern,'Horizontal');
  cxSetResourceString(@sdxVerticalFillPattern,'Vertical');
  cxSetResourceString(@sdxFDiagonalFillPattern,'FDiagonal');
  cxSetResourceString(@sdxBDiagonalFillPattern,'BDiagonal');
  cxSetResourceString(@sdxCrossFillPattern,'Cross');
  cxSetResourceString(@sdxDiagCrossFillPattern,'DiagCros');
  
  { explorer }
                                                             
  cxSetResourceString(@sdxCyclicIDReferences,'Cyclic ID references %s and %s');
  cxSetResourceString(@sdxLoadReportDataToFileTitle,'Load Report');
  cxSetResourceString(@sdxSaveReportDataToFileTitle,'Save Report As');
  cxSetResourceString(@sdxInvalidExternalStorage,'Invalid External Storage');
  cxSetResourceString(@sdxLinkIsNotIncludedInUsesClause,
    'ReportFile contains ReportLink "%0:s"' + #13#10 + 
    'Unit with declaration of "%0:s" must be included in uses clause');
  cxSetResourceString(@sdxInvalidStorageVersion,'Invalid Storage Verison: %d');
  cxSetResourceString(@sdxPSReportFiles,'Report Files');
  cxSetResourceString(@sdxReportFileLoadError,
    'Cannot load Report File "%s".' + #13#10 + 
    'File is corrupted or is locked by another User or Application.' + #13#10 + 
    #13#10 +
    'Original Report will be restored.');
  
  cxSetResourceString(@sdxNone,'(None)');
  cxSetResourceString(@sdxReportDocumentIsCorrupted,'(File is not a ReportDocument or Corrupted)');
  
  cxSetResourceString(@sdxCloseExplorerHint,'Close Explorer');
  cxSetResourceString(@sdxExplorerCaption,'Explorer');
  cxSetResourceString(@sdxExplorerRootFolderCaption,'Root');
  cxSetResourceString(@sdxNewExplorerFolderItem,'New Folder');
  cxSetResourceString(@sdxCopyOfItem,'Copy of ');
  cxSetResourceString(@sdxReportExplorer,'Report Explorer');
                                
  cxSetResourceString(@sdxDataLoadErrorText,'Cannot load Report Data');
  cxSetResourceString(@sdxDBBasedExplorerItemDataLoadError,
    'Cannot load Report Data.' + #13#10 + 
    'Data are corrupted or are locked');
  cxSetResourceString(@sdxFileBasedExplorerItemDataLoadError,
    'Cannot load Report Data.' + #13#10 + 
    'File is corruted or is locked by another User or Application');
  cxSetResourceString(@sdxDeleteNonEmptyFolderMessageText,'Folder "%s" is not Empty. Delete anyway?');
  cxSetResourceString(@sdxDeleteFolderMessageText,'Delete Folder "%s" ?');
  cxSetResourceString(@sdxDeleteItemMessageText,'Delete Item "%s" ?');
  cxSetResourceString(@sdxCannotRenameFolderText,'Cannot rename folder "%s". A folder with name "%s" already exists. Specify a different name.');
  cxSetResourceString(@sdxCannotRenameItemText,'Cannot rename item "%s". An item with name "%s" already exists. Specify a different name.');
  cxSetResourceString(@sdxOverwriteFolderMessageText,
    'This folder "%s" already contains folder named "%s".' + #13#10 + 
    #13#10 + 
    'If the items in existing folder have the same name as items in the' + #13#10 + 
    'folder you are moving or copying, they will be replaced. Do you still?' + #13#10 +
    'want to move or copy the folder?');
  cxSetResourceString(@sdxOverwriteItemMessageText,
    'This Folder "%s" already contains item named "%s".' + #13#10 + 
    #13#10 + 
    'Would you like to overwrite existing item?');
  cxSetResourceString(@sdxSelectNewRoot,'Select new Root Directory where the Reports will be stored');
  cxSetResourceString(@sdxInvalidFolderName,'Invalid Folder Name "%s"');
  cxSetResourceString(@sdxInvalidReportName,'Invalid Report Name "%s"');
  
  cxSetResourceString(@sdxExplorerBar,'Explorer');

  cxSetResourceString(@sdxMenuFileSave,'&Save');
  cxSetResourceString(@sdxMenuFileSaveAs,'Save &As...');
  cxSetResourceString(@sdxMenuFileLoad,'&Load');
  cxSetResourceString(@sdxMenuFileClose,'U&nload');
  cxSetResourceString(@sdxHintFileSave,'Save Report');
  cxSetResourceString(@sdxHintFileSaveAs,'Save Report As');
  cxSetResourceString(@sdxHintFileLoad,'Load Report');
  cxSetResourceString(@sdxHintFileClose,'Unload Report');
  
  cxSetResourceString(@sdxMenuExplorer,'E&xplorer');
  cxSetResourceString(@sdxMenuExplorerCreateFolder,'Create &Folder');
  cxSetResourceString(@sdxMenuExplorerDelete,'&Delete...');
  cxSetResourceString(@sdxMenuExplorerRename,'Rena&me');
  cxSetResourceString(@sdxMenuExplorerProperties,'&Properties...');
  cxSetResourceString(@sdxMenuExplorerRefresh,'Refresh');
  cxSetResourceString(@sdxMenuExplorerChangeRootPath,'Change Root...');
  cxSetResourceString(@sdxMenuExplorerSetAsRoot,'Set As Root');
  cxSetResourceString(@sdxMenuExplorerGoToUpOneLevel,'Up One Level');

  cxSetResourceString(@sdxHintExplorerCreateFolder,'Create New Folder');
  cxSetResourceString(@sdxHintExplorerDelete,'Delete');
  cxSetResourceString(@sdxHintExplorerRename,'Rename');
  cxSetResourceString(@sdxHintExplorerProperties,'Properties');
  cxSetResourceString(@sdxHintExplorerRefresh,'Refresh');
  cxSetResourceString(@sdxHintExplorerChangeRootPath,'Change Root');
  cxSetResourceString(@sdxHintExplorerSetAsRoot,'Set Current Folder as Root');
  cxSetResourceString(@sdxHintExplorerGoToUpOneLevel,'Up One Level');
  
  cxSetResourceString(@sdxMenuViewExplorer,'E&xplorer');
  cxSetResourceString(@sdxHintViewExplorer,'Show Explorer');

  cxSetResourceString(@sdxSummary,'Summary');
  cxSetResourceString(@sdxCreator,'Creato&r:');
  cxSetResourceString(@sdxCreationDate,'Create&d:');
 
  cxSetResourceString(@sdxMenuViewThumbnails,'Th&umbnails');
  cxSetResourceString(@sdxMenuThumbnailsLarge,'&Large Thumbnails');
  cxSetResourceString(@sdxMenuThumbnailsSmall,'&Small Thumbnails');
  
  cxSetResourceString(@sdxHintViewThumbnails,'Show Thumbnails');
  cxSetResourceString(@sdxHintThumbnailsLarge,'Switch to large thumbnails');
  cxSetResourceString(@sdxHintThumbnailsSmall,'Switch to small thumbnails');
    
  cxSetResourceString(@sdxMenuFormatTitle,'T&itle...');
  cxSetResourceString(@sdxHintFormatTitle,'Format Report Title');

  cxSetResourceString(@sdxHalf,'һ��');
  ////'Half');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxPredefinedFunctions,'Ԥ���庯��'); // dxPgsDlg.pas
  ////' Predefined Functions '); // dxPgsDlg.pas                                                                                                                                              
  cxSetResourceString(@sdxZoomParameters,'���Ų���(&P)');          // dxPSPrvwOpt.pas
  ////' Zoom &Parameters ');          // dxPSPrvwOpt.pas                                                                                                                             

  cxSetResourceString(@sdxWrapData,'��װ����');
  ////'&Wrap Data');

  {cxSetResourceString(@sdxMenuShortcutExplorer,'Explorer');
  cxSetResourceString(@sdxExplorerToolBar,'Explorer');

  cxSetResourceString(@sdxMenuShortcutThumbnails,'Thumbnails');

  { TreeView New}

 { cxSetResourceString(@sdxButtons,'Buttons');
  
  { ListView }

 { cxSetResourceString(@sdxBtnHeadersFont,'&Headers Font...');
  cxSetResourceString(@sdxHeadersTransparent,'Transparent &Headers');
  cxSetResourceString(@sdxHintListViewDesignerMessage,' Most Options Are Being Taken Into Account Only In Detailed View');
  cxSetResourceString(@sdxColumnHeaders,'&Column Headers');
  
  { Group LookAndFeel Names }

 { cxSetResourceString(@sdxReportGroupNullLookAndFeel,'Null');
  cxSetResourceString(@sdxReportGroupStandardLookAndFeel,'Standard');
  cxSetResourceString(@sdxReportGroupOfficeLookAndFeel,'Office');  
  cxSetResourceString(@sdxReportGroupWebLookAndFeel,'Web');
  
  cxSetResourceString(@sdxLayoutGroupDefaultCaption,'Layout Group');
  cxSetResourceString(@sdxLayoutItemDefaultCaption,'Layout Item');

  { Designer Previews}

  { Localize if you want (they are used inside FormatReport dialog -> ReportPreview) }
    
 { cxSetResourceString(@sdxCarManufacturerName5,'DaimlerChrysler AG');
  cxSetResourceString(@sdxCarManufacturerCountry5,'Germany');
  cxSetResourceString(@sdxCarModel5,'Maybach 62');

  cxSetResourceString(@sdxLuxurySedans,'Luxury Sedans');
  cxSetResourceString(@sdxCarManufacturer,'Manufacturer');
  cxSetResourceString(@sdxCarModel,'Model');
  cxSetResourceString(@sdxCarEngine,'Engine');
  cxSetResourceString(@sdxCarTransmission,'Transmission');
  cxSetResourceString(@sdxCarTires,'Tires');
  cxSetResourceString(@sdx760V12Manufacturer,'BMW');
  cxSetResourceString(@sdx760V12Model,'760Li V12');
  cxSetResourceString(@sdx760V12Engine,'6.0L DOHC V12 438 HP 48V DI Valvetronic 12-cylinder engine with 6.0-liter displacement, dual overhead cam valvetrain');
  cxSetResourceString(@sdx760V12Transmission,'Elec 6-Speed Automatic w/Steptronic');
  cxSetResourceString(@sdx760V12Tires,'P245/45R19 Fr - P275/40R19 Rr Performance. Low Profile tires with 245mm width, 19.0" rim');
      
  { Styles }

 { cxSetResourceString(@sdxBandHeaderStyle,'BandHeader');
  cxSetResourceString(@sdxCaptionStyle,'Caption');
  cxSetResourceString(@sdxCardCaptionRowStyle,'Card Caption Row');
  cxSetResourceString(@sdxCardRowCaptionStyle,'Card Row Caption');
  cxSetResourceString(@sdxCategoryStyle,'Category');
  cxSetResourceString(@sdxContentStyle,'Content');
  cxSetResourceString(@sdxContentEvenStyle,'Content Even Rows');
  cxSetResourceString(@sdxContentOddStyle,'Content Odd Rows');
  cxSetResourceString(@sdxFilterBarStyle,'Filter Bar');
  cxSetResourceString(@sdxFooterStyle,'Footer');
  cxSetResourceString(@sdxFooterRowStyle,'Footer Row');
  cxSetResourceString(@sdxGroupStyle,'Group');
  cxSetResourceString(@sdxHeaderStyle,'Header');
  cxSetResourceString(@sdxIndentStyle,'Indent');
  cxSetResourceString(@sdxPreviewStyle,'Preview');
  cxSetResourceString(@sdxSelectionStyle,'Selection');

  cxSetResourceString(@sdxStyles,'Styles');
  cxSetResourceString(@sdxStyleSheets,'Style Sheets');
  cxSetResourceString(@sdxBtnTexture,'&Texture...');
  cxSetResourceString(@sdxBtnTextureClear,'Cl&ear');
  cxSetResourceString(@sdxBtnColor,'Co&lor...');
  cxSetResourceString(@sdxBtnSaveAs,'Save &As...');
  cxSetResourceString(@sdxBtnRename,'&Rename...');
  
  cxSetResourceString(@sdxLoadBitmapDlgTitle,'Load Texture');
  
  cxSetResourceString(@sdxDeleteStyleSheet,'Delete StyleSheet Named "%s"?');
  cxSetResourceString(@sdxUnnamedStyleSheet,'Unnamed');
  cxSetResourceString(@sdxCreateNewStyleQueryNamePrompt,'Enter New StyleSheet Name: ');
  cxSetResourceString(@sdxStyleSheetNameAlreadyExists,'StyleSheet named "%s" Already Exists');

  cxSetResourceString(@sdxCannotLoadImage,'Cannot Load Image "%s"');
  cxSetResourceString(@sdxUseNativeStyles,'&Use Native Styles');
  cxSetResourceString(@sdxSuppressBackgroundBitmaps,'&Suppress Background Textures');
  cxSetResourceString(@sdxConsumeSelectionStyle,'Consume Selection Style');
  
  { Grid4 new }

 { cxSetResourceString(@sdxSize,'��С');
  ////'Size');
  cxSetResourceString(@sdxLevels,'Levels');
  cxSetResourceString(@sdxUnwrap,'&Unwrap');
  cxSetResourceString(@sdxUnwrapTopLevel,'Un&wrap Top Level');
  cxSetResourceString(@sdxRiseActiveToTop,'Rise Active Level onto Top');
  cxSetResourceString(@sdxCannotUseOnEveryPageModeInAggregatedState,
    'Cannot Use OnEveryPage Mode'+ #13#10 + 
    'While Performing in Aggregated State');

  cxSetResourceString(@sdxPagination,'Pagination');
  cxSetResourceString(@sdxByBands,'By Bands');
  cxSetResourceString(@sdxByColumns,'By Columns');
  cxSetResourceString(@sdxByRows,'By &Rows');
  cxSetResourceString(@sdxByTopLevelGroups,'By TopLevel Groups'); 
  cxSetResourceString(@sdxOneGroupPerPage,'One Group Per Page'); 

  {* For those who will translate *}
  {* You should also check "cxSetResourceString(@sdxCannotUseOnEveryPageMode" resource string - see above *}
  {* It was changed to "- Toggle "Unwrap" Option off on "Behaviors" Tab"*}
   
  { TL 4 }
 { cxSetResourceString(@sdxBorders,'Borders');
  cxSetResourceString(@sdxExplicitlyExpandNodes,'Explicitly Expand Nodes');
  cxSetResourceString(@sdxNodes,'&Nodes');
  cxSetResourceString(@sdxSeparators,'Separators');
  cxSetResourceString(@sdxThickness,'Thickness');
  cxSetResourceString(@sdxTLIncorrectHeadersState,
    'Cannot Use Headers OnEveryPage Mode' + #13#10 + 
    #13#10 +
    'You should either:' + #13#10 +
    '  - Set Band OnEveryPage Option On' + #13#10 +
    '  - Set Band Visible Option Off');

  { cxVerticalGrid }

 { cxSetResourceString(@sdxRows,'&Rows');

  cxSetResourceString(@sdxMultipleRecords,'&Multiple Records');
  cxSetResourceString(@sdxBestFit,'&Best Fit');
  cxSetResourceString(@sdxKeepSameRecordWidths,'&Keep Same Record Widths');
  cxSetResourceString(@sdxWrapRecords,'&Wrap Records');

  cxSetResourceString(@sdxByWrapping,'By &Wrapping');
  cxSetResourceString(@sdxOneWrappingPerPage,'&One Wrapping Per Page');

  {new in 3.01}
 { cxSetResourceString(@sdxCurrentRecord,'Current Record');
  cxSetResourceString(@sdxLoadedRecords,'Loaded Records');
  cxSetResourceString(@sdxAllRecords,'All Records');
  
  { Container Designer }
  
 { cxSetResourceString(@sdxPaginateByControlDetails,'Control Details');
  cxSetResourceString(@sdxPaginateByControls,'Controls');
  cxSetResourceString(@sdxPaginateByGroups,'Groups');
  cxSetResourceString(@sdxPaginateByItems,'Items');
  
  cxSetResourceString(@sdxControlsPlace,'Controls Place');
  cxSetResourceString(@sdxExpandHeight,'Expand Height');
  cxSetResourceString(@sdxExpandWidth,'Expand Width');
  cxSetResourceString(@sdxShrinkHeight,'Shrink Height');
  cxSetResourceString(@sdxShrinkWidth,'Shrink Width');
  
  cxSetResourceString(@sdxCheckAll,'Check &All');
  cxSetResourceString(@sdxCheckAllChildren,'Check All &Children');
  cxSetResourceString(@sdxControlsTab,'Controls');
  cxSetResourceString(@sdxExpandAll,'E&xpand All');
  cxSetResourceString(@sdxHiddenControlsTab,'Hidden Controls');
  cxSetResourceString(@sdxReportLinksTab,'Aggregated Designers');
  cxSetResourceString(@sdxAvailableLinks,'&Available Links:');
  cxSetResourceString(@sdxAggregatedLinks,'A&ggregated Links:');
  cxSetResourceString(@sdxTransparents,'Transparents');
  cxSetResourceString(@sdxUncheckAllChildren,'Uncheck &All Children');
  
  cxSetResourceString(@sdxRoot,'&Root');
  cxSetResourceString(@sdxRootBorders,'Root &Borders');
  cxSetResourceString(@sdxControls,'&Controls');
  cxSetResourceString(@sdxContainers,'C&ontainers');

  cxSetResourceString(@sdxHideCustomContainers,'&Hide Custom Containers');

  { General }
  
  // FileSize abbreviation

  {cxSetResourceString(@sdxBytes,'Bytes');
  cxSetResourceString(@sdxKiloBytes,'KB');
  cxSetResourceString(@sdxMegaBytes,'MB');
  cxSetResourceString(@sdxGigaBytes,'GB');

  // Misc.

  cxSetResourceString(@sdxThereIsNoPictureToDisplay,'There is no picture to display');
  cxSetResourceString(@sdxInvalidRootDirectory,'Directory "%s" does not exists. Continue selection ?');
  cxSetResourceString(@sdxPressEscToCancel,'Press Esc to cancel');
  cxSetResourceString(@sdxMenuFileRebuild,'&Rebuild');
  cxSetResourceString(@sdxBuildingReportStatusText,'Building report - Press Esc to cancel');
  cxSetResourceString(@sdxPrintingReportStatusText,'Printing report - Press Esc to cancel');
  
  cxSetResourceString(@sdxBuiltIn,'[BuiltIn]');
  cxSetResourceString(@sdxUserDefined,'[User Defined]');
  cxSetResourceString(@sdxNewStyleRepositoryWasCreated,'New StyleRepository "%s" was created and assigned');

  { new in PS 3.1}
 { cxSetResourceString(@sdxLineSpacing,'&Line spacing:');
  cxSetResourceString(@sdxTextAlignJustified,'Justified');
  cxSetResourceString(@sdxSampleText,'Sample Text Sample Text');
  
  cxSetResourceString(@sdxCardsRows,'&Cards');
  cxSetResourceString(@sdxTransparentRichEdits,'Transparent &RichEdit Content');

  cxSetResourceString(@sdxIncorrectFilterBarState,
    'Cannot Use FilterBar OnEveryPage Mode' + #13#10 +
    #13#10 +
    'You should either:' + #13#10 +  
    '  - Set Caption OnEveryPage Option On' + #13#10 +
    '  - Set Caption Visible Option Off');
  cxSetResourceString(@sdxIncorrectBandHeadersState2,
    'Cannot Use BandHeaders OnEveryPage Mode' + #13#10 +
    #13#10 +
    'You should either:' + #13#10 +  
    '  - Set Caption and FilterBar OnEveryPage Option On' + #13#10 + 
    '  - Set Caption and FilterBar Visible Option Off');
  cxSetResourceString(@sdxIncorrectHeadersState2,
    'Cannot Use Headers OnEveryPage Mode' + #13#10 +
    #13#10 +
    'You should either:' + #13#10 +  
    '  - Set Caption, FilterBar and Band OnEveryPage Option On' + #13#10 +
    '  - Set Caption, FilterBar and Band Visible Option Off');

 { new in PS 3.2}   
{  cxSetResourceString(@sdxAvailableReportLinks,'Available ReportLinks');
  cxSetResourceString(@sdxBtnRemoveInconsistents,'Remove Unneeded');
  cxSetResourceString(@sdxColumnHeadersOnEveryPage,'Column &Headers');
  
 { Scheduler }   

 { cxSetResourceString(@sdxNotes,'Notes');
  cxSetResourceString(@sdxTaskPad,'TaskPad');
  cxSetResourceString(@sdxPrimaryTimeZone,'Primary');
  cxSetResourceString(@sdxSecondaryTimeZone,'Secondary');
  
  cxSetResourceString(@sdxDay,'Day');
  cxSetResourceString(@sdxWeek,'Week');
  cxSetResourceString(@sdxMonth,'Month');
  
  cxSetResourceString(@sdxSchedulerSchedulerHeader,'Scheduler Header');
  cxSetResourceString(@sdxSchedulerContent,'Content');
  cxSetResourceString(@sdxSchedulerDateNavigatorContent,'DateNavigator Content');
  cxSetResourceString(@sdxSchedulerDateNavigatorHeader,'DateNavigator Header');
  cxSetResourceString(@sdxSchedulerDayHeader,'Day Header');
  cxSetResourceString(@sdxSchedulerEvent,'Event');
  cxSetResourceString(@sdxSchedulerResourceHeader,'Resource Header');
  cxSetResourceString(@sdxSchedulerNotesAreaBlank,'Notes Area (Blank)');
  cxSetResourceString(@sdxSchedulerNotesAreaLined,'Notes Area (Lined)');
  cxSetResourceString(@sdxSchedulerTaskPad,'TaskPad');
  cxSetResourceString(@sdxSchedulerTimeRuler,'Time Ruler');
  
  cxSetResourceString(@sdxPrintStyleNameDaily,'Daily');
  cxSetResourceString(@sdxPrintStyleNameWeekly,'Weekly');
  cxSetResourceString(@sdxPrintStyleNameMonthly,'Monthly');
  cxSetResourceString(@sdxPrintStyleNameDetails,'Details');
  cxSetResourceString(@sdxPrintStyleNameMemo,'Memo');
  cxSetResourceString(@sdxPrintStyleNameTrifold,'Trifold');
  
  cxSetResourceString(@sdxPrintStyleCaptionDaily,'Daily Style');
  cxSetResourceString(@sdxPrintStyleCaptionWeekly,'Weekly Style');
  cxSetResourceString(@sdxPrintStyleCaptionMonthly,'Monthly Style');
  cxSetResourceString(@sdxPrintStyleCaptionDetails,'Calendar Details Style');
  cxSetResourceString(@sdxPrintStyleCaptionMemo,'Memo Style');
  cxSetResourceString(@sdxPrintStyleCaptionTrifold,'Tri-fold Style');

  cxSetResourceString(@sdxTabPrintStyles,'Print Styles');
  
  cxSetResourceString(@sdxPrintStyleDontPrintWeekEnds,'&Don''t Print Weekends');
  cxSetResourceString(@sdxPrintStyleInclude,'Include:');
  cxSetResourceString(@sdxPrintStyleIncludeTaskPad,'Task&Pad');
  cxSetResourceString(@sdxPrintStyleIncludeNotesAreaBlank,'Notes Area (&Blank)');
  cxSetResourceString(@sdxPrintStyleIncludeNotesAreaLined,'Notes Area (&Lined)');
  cxSetResourceString(@sdxPrintStyleLayout,'&Layout:');
  cxSetResourceString(@sdxPrintStylePrintFrom,'Print &From:');
  cxSetResourceString(@sdxPrintStylePrintTo,'Print &To:');
  
  cxSetResourceString(@sdxPrintStyleDailyLayout1PPD,'1 page/day');
  cxSetResourceString(@sdxPrintStyleDailyLayout2PPD,'2 pages/day');
  
  cxSetResourceString(@sdxPrintStyleWeeklyArrange,'&Arrange:');
  cxSetResourceString(@sdxPrintStyleWeeklyArrangeT2B,'Top to bottom');
  cxSetResourceString(@sdxPrintStyleWeeklyArrangeL2R,'Left to right');
  cxSetResourceString(@sdxPrintStyleWeeklyLayout1PPW,'1 page/week');
  cxSetResourceString(@sdxPrintStyleWeeklyLayout2PPW,'2 pages/week');

  cxSetResourceString(@sdxPrintStyleMemoPrintOnlySelectedEvents,'Print Only Selected Events');

  cxSetResourceString(@sdxPrintStyleMonthlyLayout1PPM,'1 page/month');
  cxSetResourceString(@sdxPrintStyleMonthlyLayout2PPM,'2 pages/month');
  cxSetResourceString(@sdxPrintStyleMonthlyPrintExactly1MPP,'Print &Exactly One Month Per Page');
  
  cxSetResourceString(@sdxPrintStyleTrifoldSectionModeDailyCalendar,'Daily Calendar');
  cxSetResourceString(@sdxPrintStyleTrifoldSectionModeWeeklyCalendar,'Weekly Calendar');
  cxSetResourceString(@sdxPrintStyleTrifoldSectionModeMonthlyCalendar,'Monthly Calendar');
  cxSetResourceString(@sdxPrintStyleTrifoldSectionModeTaskPad,'TaskPad');
  cxSetResourceString(@sdxPrintStyleTrifoldSectionModeNotesBlank,'Notes (Blank)');
  cxSetResourceString(@sdxPrintStyleTrifoldSectionModeNotesLined,'Notes (Lined)');
  cxSetResourceString(@sdxPrintStyleTrifoldSectionLeft,'&Left Section:');
  cxSetResourceString(@sdxPrintStyleTrifoldSectionMiddle,'&Monthly Section:');
  cxSetResourceString(@sdxPrintStyleTrifoldSectionRight,'&Right Section:');

  cxSetResourceString(@sdxPrintStyleDetailsStartNewPageEach,'Start a New Page Each:');

  cxSetResourceString(@sdxSuppressContentColoration,'Suppress &Content Coloration');
  cxSetResourceString(@sdxOneResourcePerPage,'One &Resource Per Page');

  cxSetResourceString(@sdxPrintRanges,'Print Ranges');
  cxSetResourceString(@sdxPrintRangeStart,'&Start:');
  cxSetResourceString(@sdxPrintRangeEnd,'&End:');
  cxSetResourceString(@sdxHideDetailsOfPrivateAppointments,'&Hide Details of Private Appointments');
  cxSetResourceString(@sdxResourceCountPerPage,'&Resources/Page:');

  cxSetResourceString(@sdxSubjectLabelCaption,'Subject:');
  cxSetResourceString(@sdxLocationLabelCaption,'Location:');
  cxSetResourceString(@sdxStartLabelCaption,'Start:');
  cxSetResourceString(@sdxFinishLabelCaption,'End:');
  cxSetResourceString(@sdxShowTimeAsLabelCaption,'Show Time As:');
  cxSetResourceString(@sdxRecurrenceLabelCaption,'Recurrence:');
  cxSetResourceString(@sdxRecurrencePatternLabelCaption,'Recurrence Pattern:');

  //messages
  cxSetResourceString(@sdxSeeAboveMessage,'Please See Above');
  cxSetResourceString(@sdxAllDayMessage,'All Day');
  cxSetResourceString(@sdxContinuedMessage,'Continued');
  cxSetResourceString(@sdxShowTimeAsFreeMessage,'Free');
  cxSetResourceString(@sdxShowTimeAsTentativeMessage,'Tentative');
  cxSetResourceString(@sdxShowTimeAsOutOfOfficeMessage,'Out of Office');

  cxSetResourceString(@sdxRecurrenceNoneMessage,'(none)');
  cxSetResourceString(@scxRecurrenceDailyMessage,'Daily');
  cxSetResourceString(@scxRecurrenceWeeklyMessage,'Weekly');
  cxSetResourceString(@scxRecurrenceMonthlyMessage,'Monthly');
  cxSetResourceString(@scxRecurrenceYearlyMessage,'Yearly');

  //error messages
  cxSetResourceString(@sdxInconsistentTrifoldStyle,'The Tri-fold style requires at least one calendar section. ' +
    'Select Daily, Weekly, or Monthly Calendar for one of section under Options.');
  cxSetResourceString(@sdxBadTimePrintRange,'The hours to print are not valid. The start time must precede the end time.');
  cxSetResourceString(@sdxBadDatePrintRange,'The date in the End box cannot be prior to the date in the Start box.');
  cxSetResourceString(@sdxCannotPrintNoSelectedItems,'Cannot print unless an item is selected. Select an item, and then try to print again.');
  cxSetResourceString(@sdxCannotPrintNoItemsAvailable,'No items available within the specified print range.');      }

  //dxBarStrs.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@dxSBAR_LOOKUPDIALOGCAPTION , 'ѡ��ֵ');
  cxSetResourceString(@dxSBAR_LOOKUPDIALOGOK , 'ȷ��');
  cxSetResourceString(@dxSBAR_LOOKUPDIALOGCANCEL , '����');

  cxSetResourceString(@dxSBAR_DIALOGOK , 'ȷ��');
  cxSetResourceString(@dxSBAR_DIALOGCANCEL , '����');
  cxSetResourceString(@dxSBAR_COLOR_STR_0 , '��ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_1 , '��ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_2 , '��ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_3 , '���ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_4 , '����ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_5 , '��ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_6 , '��ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_7 , '��ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_8 , '��ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_9 , '��ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_10 , '�Ұ�ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_11 , '��ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_12 , '��ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_13 , '�Ϻ�ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_14 , 'ǳ��ɫ');
  cxSetResourceString(@dxSBAR_COLOR_STR_15 , '��ɫ');
  cxSetResourceString(@dxSBAR_COLORAUTOTEXT , '(�Զ�)');
  cxSetResourceString(@dxSBAR_COLORCUSTOMTEXT , '(�Զ���)');
  cxSetResourceString(@dxSBAR_DATETODAY , '����');
  cxSetResourceString(@dxSBAR_DATECLEAR , '���');
  cxSetResourceString(@dxSBAR_DATEDIALOGCAPTION , '����ѡ��');
  cxSetResourceString(@dxSBAR_TREEVIEWDIALOGCAPTION , '��Ŀѡ��');
  cxSetResourceString(@dxSBAR_IMAGEDIALOGCAPTION , '��Ŀѡ��');
  cxSetResourceString(@dxSBAR_IMAGEINDEX , 'ͼ������');
  cxSetResourceString(@dxSBAR_IMAGETEXT , '�ı�');
  cxSetResourceString(@dxSBAR_PLACEFORCONTROL , 'λ������ ');
  cxSetResourceString(@dxSBAR_CANTASSIGNCONTROL , '���޷�������ͬ�Ŀ��Ƹ������TdxBarControlContainerItem.');
  cxSetResourceString(@dxSBAR_CXEDITVALUEDIALOGCAPTION, '����ֵ');

  cxSetResourceString(@dxSBAR_WANTTORESETTOOLBAR , '��ȷ�����������ѱ��ı����ƵĹ�����''%s''?');
  cxSetResourceString(@dxSBAR_WANTTORESETUSAGEDATA , '����ɾ�������¼������ͻָ�Ĭ�ϵĲ˵��͹������ɼ���������. �����ᱻȡ�������ڵĶ���.   ��ȷ������?');
  cxSetResourceString(@dxSBAR_BARMANAGERMORETHANONE  , 'һ��FormӦ��ֻ��һ��Ψһ��TdxBarManager');
  cxSetResourceString(@dxSBAR_BARMANAGERBADOWNER , 'TdxBarManagerӦ���������ѵ� - TForm (TCustomForm)');
  cxSetResourceString(@dxSBAR_NOBARMANAGERS , '����û�п��õ�TdxBarManagers');
  cxSetResourceString(@dxSBAR_WANTTODELETETOOLBAR , '��ȷ��Ҫɾ�����������''%s''?');
  cxSetResourceString(@dxSBAR_WANTTODELETECATEGORY , '��ȷ��Ҫɾ���������''%s''?');
  cxSetResourceString(@dxSBAR_WANTTOCLEARCOMMANDS , '��ȷ��Ҫɾ������������е�����''%s''?');
  cxSetResourceString(@dxSBAR_RECURSIVEMENUS , '���޷������ݹ������Ŀ');
  cxSetResourceString(@dxSBAR_COMMANDNAMECANNOTBEBLANK , '�������Ʋ���Ϊ��. ������һ������.');
  cxSetResourceString(@dxSBAR_TOOLBAREXISTS , '��ָ���Ĺ������Ѿ����� ''%s'' . ����������.');
  cxSetResourceString(@dxSBAR_RECURSIVEGROUPS , '���޷������ݹ����');
  cxSetResourceString(@dxSBAR_WANTTODELETECOMPLEXITEM, 'һ��ѡ�еĶ����м�����Ӧ�����ӣ��Ƿ�ɾ����Щ���ӣ�');
  cxSetResourceString(@dxSBAR_CANTPLACEQUICKACCESSGROUPBUTTON, '��ֻ�ܽ�TdxRibbonQuickAccessGroupButton������TdxRibbonQuickAccessToolbar��');
  cxSetResourceString(@dxSBAR_QUICKACCESSGROUPBUTTONTOOLBARNOTDOCKEDINRIBBON, '���ٹ���������ͣ����Ribbon');
  cxSetResourceString(@dxSBAR_QUICKACCESSALREADYHASGROUPBUTTON, '���ٹ������Ѿ�������ͬ��Toolbar');
  cxSetResourceString(@dxSBAR_CANTPLACESEPARATOR, '��Ŀ���ܷ�����ָ����Toolbar��');
  cxSetResourceString(@dxSBAR_CANTPLACERIBBONGALLERY, '��ֻ�ܽ�TdxRibbonGalleryItem���õ�Ribbon��');


  cxSetResourceString(@dxSBAR_CANTMERGEBARMANAGER , 'You cannot merge with the specified bar manager');
  cxSetResourceString(@dxSBAR_CANTMERGETOOLBAR , 'You cannot merge with the specified toolbar');
  cxSetResourceString(@dxSBAR_CANTMERGEWITHMERGEDTOOLBAR , 'You cannot merge a toolbar with a toolbar that is already merged');
  cxSetResourceString(@dxSBAR_CANTUNMERGETOOLBAR , 'You cannot unmerge the specified toolbar');
  cxSetResourceString(@dxSBAR_ONEOFTOOLBARSALREADYMERGED , 'One of the toolbars of the specified bar manager is already merged');
  cxSetResourceString(@dxSBAR_ONEOFTOOLBARSHASMERGEDTOOLBARS , 'One of the toolbars of the specified bar manager has merged toolbars');
  cxSetResourceString(@dxSBAR_TOOLBARHASMERGEDTOOLBARS , 'The ''%s'' toolbar has merged toolbars');
  cxSetResourceString(@dxSBAR_TOOLBARSALREADYMERGED , 'The ''%s'' toolbar is already merged with the ''%s'' toolbar');
  cxSetResourceString(@dxSBAR_TOOLBARSARENOTMERGED , 'The ''%s'' toolbar is not merged with the ''%s'' toolbar');


  cxSetResourceString(@dxSBAR_DEFAULTCATEGORYNAME , 'Ĭ��');
  // begin DesignTime section
  cxSetResourceString(@dxSBAR_NEWBUTTONCAPTION , 'New Button');
  cxSetResourceString(@dxSBAR_NEWITEMCAPTION , 'New Item');
  cxSetResourceString(@dxSBAR_NEWRIBBONGALLERYITEMCAPTION , 'New Gallery');
  cxSetResourceString(@dxSBAR_NEWSEPARATORCAPTION , 'New Separator');
  cxSetResourceString(@dxSBAR_NEWSUBITEMCAPTION , 'New SubItem');

  cxSetResourceString(@dxSBAR_CP_ADDSEPARATOR , 'Add &Separator');
  cxSetResourceString(@dxSBAR_CP_ADDDXITEM , 'Add &Item');
  cxSetResourceString(@dxSBAR_CP_ADDCXITEM , 'Add &cxEditItem');
  cxSetResourceString(@dxSBAR_CP_ADDGROUPBUTTON , 'Add Gro&upButton');
  cxSetResourceString(@dxSBAR_CP_DELETEITEM , 'Delete Item');
  cxSetResourceString(@dxSBAR_CP_DELETELINK , 'Delete Link');
  // end DesignTime section

  cxSetResourceString(@dxSBAR_CP_ADDSUBITEM , '�������Ŀ(&S)');
  cxSetResourceString(@dxSBAR_CP_ADDBUTTON , '��Ӱ�ť(&B)');
//  cxSetResourceString(@dxSBAR_CP_ADDITEM , '�����Ŀ(&I)');
//  cxSetResourceString(@dxSBAR_CP_DELETEBAR , 'ɾ����');

  cxSetResourceString(@dxSBAR_CP_RESET , '��������(&R)');
  cxSetResourceString(@dxSBAR_CP_DELETE , 'ɾ��(&D)');
  cxSetResourceString(@dxSBAR_CP_NAME , '����(&N):');
  cxSetResourceString(@dxSBAR_CP_CAPTION , '����(&C):'); // is the same as dxSBAR_CP_NAME (at design-time)
  cxSetResourceString(@dxSBAR_CP_BUTTONPAINTSTYLEMENU, '��ť����(&s)');
  cxSetResourceString(@dxSBAR_CP_DEFAULTSTYLE , 'Ĭ������(&U)');
  cxSetResourceString(@dxSBAR_CP_TEXTONLYALWAYS , 'Ψһ�ı�(ʼ��)(&T)');
  cxSetResourceString(@dxSBAR_CP_TEXTONLYINMENUS , 'Ψһ�ı�(�ڲ˵�)(&O)');
  cxSetResourceString(@dxSBAR_CP_IMAGEANDTEXT , 'ͼ����ı�(&A)');
  cxSetResourceString(@dxSBAR_CP_BEGINAGROUP , '��ʼһ����(&G)');
  cxSetResourceString(@dxSBAR_CP_VISIBLE , '�ɼ���(&V)');
  cxSetResourceString(@dxSBAR_CP_MOSTRECENTLYUSED , '�󲿷����ʹ�ù���(&M)');
  // begin DesignTime section
  cxSetResourceString(@dxSBAR_CP_POSITIONMENU , '&Position');
  cxSetResourceString(@dxSBAR_CP_VIEWLEVELSMENU , 'View&Levels');
  cxSetResourceString(@dxSBAR_CP_ALLVIEWLEVELS , 'All');
  cxSetResourceString(@dxSBAR_CP_SINGLEVIEWLEVELITEMSUFFIX , ' ONLY');
  cxSetResourceString(@dxSBAR_CP_BUTTONGROUPMENU , 'ButtonG&roup');
  cxSetResourceString(@dxSBAR_CP_BUTTONGROUP , 'Group');
  cxSetResourceString(@dxSBAR_CP_BUTTONUNGROUP , 'Ungroup');
  // end DesignTime section

  cxSetResourceString(@dxSBAR_ADDEX , '���...');
  cxSetResourceString(@dxSBAR_RENAMEEX , '��������...');
  cxSetResourceString(@dxSBAR_DELETE , 'ɾ��');
  cxSetResourceString(@dxSBAR_CLEAR , '���');
  cxSetResourceString(@dxSBAR_VISIBLE , '�ɼ���');
  cxSetResourceString(@dxSBAR_OK , 'ȷ��');
  cxSetResourceString(@dxSBAR_CANCEL , '����');
  cxSetResourceString(@dxSBAR_SUBMENUEDITOR , '�Ӳ˵��༭...');
  cxSetResourceString(@dxSBAR_SUBMENUEDITORCAPTION , '�������Ӳ˵��༭');
  cxSetResourceString(@dxSBAR_INSERTEX , '����...');

  cxSetResourceString(@dxSBAR_MOVEUP , '����');
  cxSetResourceString(@dxSBAR_MOVEDOWN , '����');
  cxSetResourceString(@dxSBAR_POPUPMENUEDITOR , '��ݲ˵��༭...');
  cxSetResourceString(@dxSBAR_TABSHEET1 , ' ������ ');
  cxSetResourceString(@dxSBAR_TABSHEET2 , ' ���� ');
  cxSetResourceString(@dxSBAR_TABSHEET3 , ' ѡ�� ');
  cxSetResourceString(@dxSBAR_TOOLBARS , '������(&A):');
  cxSetResourceString(@dxSBAR_TNEW , '�µ�(&N)...');
  cxSetResourceString(@dxSBAR_TRENAME , '������(&E)...');
  cxSetResourceString(@dxSBAR_TDELETE , 'ɾ��(&D)');
  cxSetResourceString(@dxSBAR_TRESET , '��������(&R)...');
  cxSetResourceString(@dxSBAR_CLOSE , '�ر�');
  cxSetResourceString(@dxSBAR_CAPTION , '����');
  cxSetResourceString(@dxSBAR_CATEGORIES , '����(&G):');
  cxSetResourceString(@dxSBAR_COMMANDS , '����(&D):');
  cxSetResourceString(@dxSBAR_DESCRIPTION , '����  ');

  cxSetResourceString(@dxSBAR_MDIMINIMIZE , '��С������');
  cxSetResourceString(@dxSBAR_MDIRESTORE , '�ָ�����');
  cxSetResourceString(@dxSBAR_MDICLOSE , '�رմ���');
  cxSetResourceString(@dxSBAR_CUSTOMIZE , '����(&C)...');
  cxSetResourceString(@dxSBAR_ADDREMOVEBUTTONS , '��ӻ�ɾ��һ����ť(&A)');
  cxSetResourceString(@dxSBAR_MOREBUTTONS , '����İ�ť');
  cxSetResourceString(@dxSBAR_RESETTOOLBAR , '�������ù�����(&R)');
  cxSetResourceString(@dxSBAR_EXPAND , '��չ (Ctrl-Down)');
  cxSetResourceString(@dxSBAR_DRAGTOMAKEMENUFLOAT , '��ҷʹ�˵��ڴ���Ư��');

  cxSetResourceString(@dxSBAR_MORECOMMANDS , '���������(&M)...');
  cxSetResourceString(@dxSBAR_SHOWBELOWRIBBON , '��Ribbon�·���ʾ���ٷ��ʹ�����(&S)');
  cxSetResourceString(@dxSBAR_SHOWABOVERIBBON , '��Ribbon�Ϸ���ʾ���ٷ��ʹ�����(&S)');
  cxSetResourceString(@dxSBAR_MINIMIZERIBBON , '��С��Ribbon(&n)');
  cxSetResourceString(@dxSBAR_ADDTOQAT , '��ӿ��ٷ��ʹ�����(&A)');
  cxSetResourceString(@dxSBAR_ADDTOQATITEMNAME , '���%s�����ٷ��ʹ�����(&A)');
  cxSetResourceString(@dxSBAR_REMOVEFROMQAT , '�ӿ��ٷ��ʹ��������Ƴ�(&R)');
  cxSetResourceString(@dxSBAR_CUSTOMIZEQAT , '�Զ�����ٷ��ʹ�����');
  cxSetResourceString(@dxSBAR_ADDGALLERYNAME , 'ͼ��');
  //Gallery');
  {
  cxSetResourceString(@dxSBAR_SHOWALLGALLERYGROUPS , '��ʾ������');
  //Show all groups');
  cxSetResourceString(@dxSBAR_HIDEALLGALLERYGROUPS , '����������');
  //Hide all groups');
  cxSetResourceString(@dxSBAR_CLEARGALLERYFILTER , '�������');
  //Clear filter');
  cxSetResourceString(@dxSBAR_GALLERYEMPTYFILTERCAPTION , '<��>');
  //<empty>');
  }
  cxSetResourceString(@dxSBAR_TOOLBARNEWNAME  , '���� ');
  cxSetResourceString(@dxSBAR_CATEGORYADD  , '�������');
  cxSetResourceString(@dxSBAR_CATEGORYINSERT  , '�������');
  cxSetResourceString(@dxSBAR_CATEGORYRENAME  , '������������');
  cxSetResourceString(@dxSBAR_TOOLBARADD  , '��ӹ�����');
  cxSetResourceString(@dxSBAR_TOOLBARRENAME  , '��������������');
  cxSetResourceString(@dxSBAR_CATEGORYNAME  , '��������(&C):');
  cxSetResourceString(@dxSBAR_TOOLBARNAME  , '����������(&T):');
  cxSetResourceString(@dxSBAR_CUSTOMIZINGFORM , '������״...');

  cxSetResourceString(@dxSBAR_MODIFY , '... �޸�');
  cxSetResourceString(@dxSBAR_PERSMENUSANDTOOLBARS , '���Ի��˵��͹�����  ');
  cxSetResourceString(@dxSBAR_MENUSSHOWRECENTITEMS , '�ڲ˵���ʾ�����ʹ�õ��������(&N)');
  cxSetResourceString(@dxSBAR_SHOWFULLMENUSAFTERDELAY , '���ݶ��ӳٺ���ʾ�����˵�(&U)');
  cxSetResourceString(@dxSBAR_RESETUSAGEDATA , '��������ʹ�õ�����(&R)');

  cxSetResourceString(@dxSBAR_OTHEROPTIONS , '����  ');
  cxSetResourceString(@dxSBAR_LARGEICONS , '��ͼ��(&L)');
  cxSetResourceString(@dxSBAR_HINTOPT1 , '�ڹ���������ʾ������ʾ(&T)');
  cxSetResourceString(@dxSBAR_HINTOPT2 , '�ڹ�����ʾ����ʾ��ݼ�(&H)');
  cxSetResourceString(@dxSBAR_MENUANIMATIONS , '��̬�˵�(&M):');
  cxSetResourceString(@dxSBAR_MENUANIM1 , '(��)');
  cxSetResourceString(@dxSBAR_MENUANIM2 , '����');
  cxSetResourceString(@dxSBAR_MENUANIM3 , '��չ');
  cxSetResourceString(@dxSBAR_MENUANIM4 , '����');
  cxSetResourceString(@dxSBAR_MENUANIM5 , '����');

  cxSetResourceString(@dxSBAR_CANTFINDBARMANAGERFORSTATUSBAR , 'A bar manager cannot be found for the status bar');

  cxSetResourceString(@dxSBAR_BUTTONDEFAULTACTIONDESCRIPTION , 'Press');

  cxSetResourceString(@dxSBAR_GDIPLUSNEEDED , '%s requires the Microsoft GDI+ library to be installed');
  cxSetResourceString(@dxSBAR_RIBBONMORETHANONE  , 'There should be only one %s instance on the form');
  cxSetResourceString(@dxSBAR_RIBBONBADOWNER , '%s should have TCustomForm as its Owner');
  cxSetResourceString(@dxSBAR_RIBBONBADPARENT , '%s should have TCustomForm as its Parent');
  cxSetResourceString(@dxSBAR_RIBBONADDTAB , '��� Tab');
  cxSetResourceString(@dxSBAR_RIBBONDELETETAB , 'ɾ�� Tab');
  cxSetResourceString(@dxSBAR_RIBBONADDEMPTYGROUP , '�������');
  //Add Empty Group');
  cxSetResourceString(@dxSBAR_RIBBONADDGROUPWITHTOOLBAR , '��Toolbar�м�����');
  // Add Group With Toolbar');
  cxSetResourceString(@dxSBAR_RIBBONDELETEGROUP , 'ɾ�� Group');

  cxSetResourceString(@dxSBAR_ACCESSIBILITY_RIBBONNAME , 'Ribbon');
  cxSetResourceString(@dxSBAR_ACCESSIBILITY_RIBBONTABCOLLECTIONNAME , 'Ribbon Tabs');


  cxSetResourceString(@scxGridChartCategoriesDisplayText, '����');

  cxSetResourceString(@scxGridChartValueHintFormat,'%s for %s is %s');  // series display text, category, value
  cxSetResourceString(@scxGridChartPercentValueTickMarkLabelFormat,'0%');

  cxSetResourceString(@scxGridChartToolBoxDataLevels,'���ݲ�:');
  cxSetResourceString(@scxGridChartToolBoxDataLevelSelectValue,'ѡ���ֵ');
  cxSetResourceString(@scxGridChartToolBoxCustomizeButtonCaption,'ѡ����ʽ');

  cxSetResourceString(@scxGridChartNoneDiagramDisplayText,'û��ͼ��');
  cxSetResourceString(@scxGridChartColumnDiagramDisplayText,'����ͼ');
  cxSetResourceString(@scxGridChartBarDiagramDisplayText,'����ͼ');
  cxSetResourceString(@scxGridChartLineDiagramDisplayText,'����ͼ');
  cxSetResourceString(@scxGridChartAreaDiagramDisplayText,'���ͼ');
  cxSetResourceString(@scxGridChartPieDiagramDisplayText,'��ͼ');

  cxSetResourceString(@scxGridChartCustomizationFormSeriesPageCaption , 'ϵ��');
  cxSetResourceString(@scxGridChartCustomizationFormSortBySeries , '����:');
  cxSetResourceString(@scxGridChartCustomizationFormNoSortedSeries , '<��ѡ��>');
  cxSetResourceString(@scxGridChartCustomizationFormDataGroupsPageCaption , '���ݷ���');
  cxSetResourceString(@scxGridChartCustomizationFormOptionsPageCaption , 'ѡ��');

  cxSetResourceString(@scxGridChartLegend , 'ͼ��');
  cxSetResourceString(@scxGridChartLegendKeyBorder , '���ڱ߽�ֵ'); //'Key Border';
  cxSetResourceString(@scxGridChartPosition , 'λ��');
  cxSetResourceString(@scxGridChartPositionDefault , 'Ĭ��');
  cxSetResourceString(@scxGridChartPositionNone , '��');
  cxSetResourceString(@scxGridChartPositionLeft , '��');
  cxSetResourceString(@scxGridChartPositionTop , '��');
  cxSetResourceString(@scxGridChartPositionRight , '��');
  cxSetResourceString(@scxGridChartPositionBottom , '��');
  cxSetResourceString(@scxGridChartAlignment , '����');
  cxSetResourceString(@scxGridChartAlignmentDefault , 'Ĭ��');
  cxSetResourceString(@scxGridChartAlignmentStart , '��ʼ');
  cxSetResourceString(@scxGridChartAlignmentCenter , '�м�');
  cxSetResourceString(@scxGridChartAlignmentEnd , '��β');
  cxSetResourceString(@scxGridChartOrientation , '����');
  cxSetResourceString(@scxGridChartOrientationDefault , 'Ĭ��');
  cxSetResourceString(@scxGridChartOrientationHorizontal , 'ˮƽ');
  cxSetResourceString(@scxGridChartOrientationVertical , '��ֱ');
  cxSetResourceString(@scxGridChartBorder , '�߿�');
  cxSetResourceString(@scxGridChartTitle , '����');
  cxSetResourceString(@scxGridChartToolBox,'������');
  cxSetResourceString(@scxGridChartDiagramSelector , 'ͼ����ʽѡ����');
  cxSetResourceString(@scxGridChartOther , '����');
  cxSetResourceString(@scxGridChartValueHints , '��ʾֵ');

//------------------------------------------------------------------------------
// dxNavBarConsts
// Office11Views popup menu captions
//------------------------------------------------------------------------------
  cxSetResourceString(@sdxNavBarOffice11ShowMoreButtons , '��ʾ���ఴť...(&M)');
  //Show &More Buttons
  cxSetResourceString(@sdxNavBarOffice11ShowFewerButtons , '��ʾ���ٰ�ť...(&F)');
  //Show &Fewer Buttons
  cxSetResourceString(@sdxNavBarOffice11AddRemoveButtons , '���ɾ����ť...(&A)');
  //&Add or Remove Buttons
end;

initialization
  ApplyChineseResourceString;
  //��������
end.

