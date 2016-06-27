{*******************************************************************************
  作者: dmzn@163.com 2008-8-11
  描述: 控件包DevExpress汉化单元

  备注:
  &.编写代码时,将本单元Uses到项目中即可.
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
  cxSetResourceString(@scxUnsupportedExport, '不提供的输出类型: %1');
  //'Unsupported export type: %1');
  cxSetResourceString(@scxStyleManagerKill, '样式管理器正在被使用或不能释放');
  //'The Style Manager is currently being used elsewhere and can not be released at this stage');
  cxSetResourceString(@scxStyleManagerCreate, '不能创建样式管理器');
  //'Can''t create style manager');

  cxSetResourceString(@scxExportToHtml, '输出到网页 (*.html)');
  //'Export to Web page (*.html)');
  cxSetResourceString(@scxExportToXml, '输出到XML文档 (*.xml)');
  //'Export to XML document (*.xml)');
  cxSetResourceString(@scxExportToText, '输出到文本文件 (*.txt)');
  //'Export to text format (*.txt)');

  cxSetResourceString(@scxEmptyExportCache, '输出缓冲为空');
  //'Export cache is empty');
  cxSetResourceString(@scxIncorrectUnion, '不正确的单元组合');
  //'Incorrect union of cells');
  cxSetResourceString(@scxIllegalWidth, '非法的列宽');
  //'Illegal width of the column');
  cxSetResourceString(@scxInvalidColumnRowCount, '无效的行数或列数');
  //'Invalid column or row count');
  cxSetResourceString(@scxIllegalHeight, '非法的行高');
  //'Illegal height of the row');
  cxSetResourceString(@scxInvalidColumnIndex, '列标 %d 超出范围');
  //'The column index %d out of bounds');
  cxSetResourceString(@scxInvalidRowIndex, '行号 %d 超出范围');
  //'The row index %d out of bounds');
  cxSetResourceString(@scxInvalidStyleIndex, '无效的样式索引 %d');
  //'Invalid style index %d');

  cxSetResourceString(@scxExportToExcel, '输出到 MS Excel文件 (*.xls)');
  //'Export to MS Excel (*.xls)');
  cxSetResourceString(@scxWorkbookWrite, '写 XLS 文件出错');
  cxSetResourceString(@scxInvalidCellDimension, '无效的单元维度');
  //'Invalid cell dimension');
  cxSetResourceString(@scxBoolTrue, '真');
  //'True');
  cxSetResourceString(@scxBoolFalse, '假');
  //'False';

  //cxLibraryStrs.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@scxCantCreateRegistryKey, '不能创建注册表键值: \%s');
  //'Can''t create the registry key: \%s');
  cxSetResourceString(@scxCantOpenRegistryKey, '不能打开注册表键值: \%s');
  //'Can''t open the registry key: \%s';
  cxSetResourceString(@scxErrorStoreObject, '保存 %s 对象错误');
  //'Error store %s object';

  {$IFNDEF DELPHI5}
  cxSetResourceString(@scxInvalidPropertyElement, '无效的属性元素: %s');
  //'Invalid property element: %s');
  {$ENDIF}
  cxSetResourceString(@scxConverterCantCreateStyleRepository, '不能创建Style Repository');
  //'Can''t create the Style Repository');

  cxSetResourceString(@cxSDateToday, '今天');
  //'today'
  cxSetResourceString(@cxSDateYesterday, '昨天');
  //'yesterday'
  cxSetResourceString(@cxSDateTomorrow, '明天');
  //tomorrow
  cxSetResourceString(@cxSDateSunday, '星期日');
  //Sunday
  cxSetResourceString(@cxSDateMonday, '星期一');
  //Monday
  cxSetResourceString(@cxSDateTuesday, '星期二');
  //Tuesday
  cxSetResourceString(@cxSDateWednesday, '星期三');
  //Wednesday
  cxSetResourceString(@cxSDateThursday, '星期四');
  //Thursday
  cxSetResourceString(@cxSDateFriday, '星期五');
  //Friday
  cxSetResourceString(@cxSDateSaturday, '星期六');
  //Saturday
  cxSetResourceString(@cxSDateFirst, '第一天');
  //first
  cxSetResourceString(@cxSDateSecond, '第二天');
  //second
  cxSetResourceString(@cxSDateThird, '第三天');
  //third
  cxSetResourceString(@cxSDateFourth, '第四天');
  //fourth
  cxSetResourceString(@cxSDateFifth, '第五天');
  //fifth
  cxSetResourceString(@cxSDateSixth, '第六天');
  //sixth
  cxSetResourceString(@cxSDateSeventh, '第七天');
  //seventh
  cxSetResourceString(@cxSDateBOM, 'bom');
  cxSetResourceString(@cxSDateEOM, 'eom');
  cxSetResourceString(@cxSDateNow, '当前');
  //Now

  //cxGridStrs.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@scxGridRecursiveLevels, '您不能创建递归层');
  //'You cannot create recursive levels');

  cxSetResourceString(@scxGridDeletingConfirmationCaption, '提示');
  //'Confirm');
  cxSetResourceString(@scxGridDeletingFocusedConfirmationText, '删除数据吗?');
  //'Delete record?');
  cxSetResourceString(@scxGridDeletingSelectedConfirmationText, '删除所有选定的记录吗?');

  cxSetResourceString(@scxGridNoDataInfoText, '<没有任何记录>');

  cxSetResourceString(@scxGridNewItemRowInfoText, '单击此处添加一新行');
  //'Click here to add a new row');

  cxSetResourceString(@scxGridFilterIsEmpty, '<数据过滤条件为空>');
  //'<Filter is Empty>');

  cxSetResourceString(@scxGridCustomizationFormCaption, '定制');
  //'Customization');
  cxSetResourceString(@scxGridCustomizationFormColumnsPageCaption, '列');
  cxSetResourceString(@scxGridGroupByBoxCaption, '把列标题拖放到此处使记录按此列进行分组');
  //'Drag a column header here to group by that column');
  cxSetResourceString(@scxGridFilterCustomizeButtonCaption, '定制...');
  //'Customize...');
  cxSetResourceString(@scxGridColumnsQuickCustomizationHint, '点击选择可视列');
  // 'Click here to select visible columns');

  cxSetResourceString(@scxGridCustomizationFormBandsPageCaption, '区域');
  // 'Bands');
  cxSetResourceString(@scxGridBandsQuickCustomizationHint, '点击选择可视区域');
  //'Click here to select visible bands');

  cxSetResourceString(@scxGridCustomizationFormRowsPageCaption, '行'); // 'Rows');

  cxSetResourceString(@scxGridConverterIntermediaryMissing, '缺少一个中间组件!'#13#10'请添加一个 %s 组件到窗体.');
  //'Missing an intermediary component!'#13#10'Please add a %s component to the form.');
  cxSetResourceString(@scxGridConverterNotExistGrid, 'cxGrid 不存在');
  //'cxGrid does not exist');
  cxSetResourceString(@scxGridConverterNotExistComponent, '组件不存在');
  //'Component does not exist');
  cxSetResourceString(@scxImportErrorCaption, '导入错误');
  //'Import error');

  cxSetResourceString(@scxNotExistGridView, 'Grid 视图不存在');
  //'Grid view does not exist');
  cxSetResourceString(@scxNotExistGridLevel, '活动的 grid 层不存在');
  //'Active grid level does not exist');
  cxSetResourceString(@scxCantCreateExportOutputFile, '不能建立导出文件');
  //'Can''t create the export output file');

  cxSetResourceString(@cxSEditRepositoryExtLookupComboBoxItem,
    'ExtLookupComboBox|Represents an ultra-advanced lookup using the QuantumGrid as its drop down control');

  cxSetResourceString(@scxGridChartValueHintFormat, '%s for %s is %s');
  // series display text, category, value     

  //cxGridPopupMenuConsts.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@cxSGridNone, '无');
  //'None');

  //Header popup menu captions
  cxSetResourceString(@cxSGridSortColumnAsc, '升序');
  //'Sort Ascending');
  cxSetResourceString(@cxSGridSortColumnDesc, '降序');
  //'Sort Descending');
  cxSetResourceString(@cxSGridClearSorting, '清除排序');

  //'Clear Sorting');
  cxSetResourceString(@cxSGridGroupByThisField, '按照此字段分组');
  //'Group By This Field');
  cxSetResourceString(@cxSGridRemoveThisGroupItem, '从该组删除');
  //'Remove from grouping');
  cxSetResourceString(@cxSGridGroupByBox, '显示/隐藏分组框');
  //'Group By Box');
  cxSetResourceString(@cxSGridAlignmentSubMenu, '对齐');
  //'Alignment');
  cxSetResourceString(@cxSGridAlignLeft, '左对齐');
  //'Align Left');
  cxSetResourceString(@cxSGridAlignRight, '右对齐');
  //'Align Right');
  cxSetResourceString(@cxSGridAlignCenter, '居中对齐');
  //'Align Center');
  cxSetResourceString(@cxSGridRemoveColumn, '删除此列');
  //'Remove This Column');
  cxSetResourceString(@cxSGridFieldChooser, '选择字段');
  //'Field Chooser');
  cxSetResourceString(@cxSGridBestFit, '适合列宽');
  //'Best Fit');
  cxSetResourceString(@cxSGridBestFitAllColumns, '适合列宽 (所有列)');
  //'Best Fit (all columns)');
  cxSetResourceString(@cxSGridShowFooter, '脚注');
  //'Footer');
  cxSetResourceString(@cxSGridShowGroupFooter, '组脚注');
  //'Group Footers');

  //Footer popup menu captions
  cxSetResourceString(@cxSGridSumMenuItem, '合计');
  //'Sum');
  cxSetResourceString(@cxSGridMinMenuItem, '最小');
  //'Min');
  cxSetResourceString(@cxSGridMaxMenuItem, '最大');
  //'Max');
  cxSetResourceString(@cxSGridCountMenuItem, '计数');
  //'Count');
  cxSetResourceString(@cxSGridAvgMenuItem, '平均');
  //'Average');
  cxSetResourceString(@cxSGridNoneMenuItem, '无');
  //'None');

  //dxExtCtrlsStrs.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@sdxAutoColorText, '自动');
  ////'Auto');
  cxSetResourceString(@sdxCustomColorText, '定制...');
  ////'Custom...');

  cxSetResourceString(@sdxSysColorScrollBar, '滚动条');
  ////'ScrollBar');
  cxSetResourceString(@sdxSysColorBackground, '背景');
  ////'Background');
  cxSetResourceString(@sdxSysColorActiveCaption, '动作标题');
  ////'Active Caption');
  cxSetResourceString(@sdxSysColorInactiveCaption, '不活动标题');
  ////'Inactive Caption');
  cxSetResourceString(@sdxSysColorMenu, '菜单');
  ////'Menu');
  cxSetResourceString(@sdxSysColorWindow, '窗口');
  ////'Window');
  cxSetResourceString(@sdxSysColorWindowFrame, '窗口框架');
  ////'Window Frame');
  cxSetResourceString(@sdxSysColorMenuText, '菜单文本');
  ////'Menu Text');
  cxSetResourceString(@sdxSysColorWindowText, '窗口文本t');
  ////'Window Text');
  cxSetResourceString(@sdxSysColorCaptionText, '标题文本');
  ////'Caption Text');
  cxSetResourceString(@sdxSysColorActiveBorder, '活动边框');
  ////'Active Border');
  cxSetResourceString(@sdxSysColorInactiveBorder, '不活动边框');
  ////'Inactive Border');
  cxSetResourceString(@sdxSysColorAppWorkSpace, '程序工作空间');
  ////'App Workspace');
  cxSetResourceString(@sdxSysColorHighLight, '高亮');
  ////'Highlight');
  cxSetResourceString(@sdxSysColorHighLighText, '高亮文本');
  ////'Highlight Text');
  cxSetResourceString(@sdxSysColorBtnFace, '按钮表面');
  ////'Button Face');
  cxSetResourceString(@sdxSysColorBtnShadow, '按钮阴影');
  ////'Button Shadow');
  cxSetResourceString(@sdxSysColorGrayText, '灰色文本');
  ////'Gray Text');
  cxSetResourceString(@sdxSysColorBtnText, '按钮文本');
  ////'Button Text');
  cxSetResourceString(@sdxSysColorInactiveCaptionText, '不活动的标题文本');
  ////'Inactive Caption Text');
  cxSetResourceString(@sdxSysColorBtnHighligh, '按钮高亮');
  ////'Button Highlight');
  cxSetResourceString(@sdxSysColor3DDkShadow, '3DDk 阴影');
  ////'3DDk Shadow');
  cxSetResourceString(@sdxSysColor3DLight, '3D 明亮');
  ////'3DLight');
  cxSetResourceString(@sdxSysColorInfoText, '信息文本');
  ////'Info Text');
  cxSetResourceString(@sdxSysColorInfoBk, '信息背景');
  ////'InfoBk');

  cxSetResourceString(@sdxPureColorBlack, '黑');
  ////'Black');
  cxSetResourceString(@sdxPureColorRed, '红');
  ////'Red');
  cxSetResourceString(@sdxPureColorLime, '橙');
  ////'Lime');
  cxSetResourceString(@sdxPureColorYellow, '黄');
  ////'Yellow');
  cxSetResourceString(@sdxPureColorGreen, '绿');
  ////'Green');
  cxSetResourceString(@sdxPureColorTeal, '青');
  ////'Teal');
  cxSetResourceString(@sdxPureColorAqua, '浅绿');
  ////'Aqua');
  cxSetResourceString(@sdxPureColorBlue, '蓝');
  ////'Blue');
  cxSetResourceString(@sdxPureColorWhite, '白');
  ////'White');
  cxSetResourceString(@sdxPureColorOlive, '浅绿');
  ////'Olive');
  cxSetResourceString(@sdxPureColorMoneyGreen, '黄绿');
  ////'Money Green');
  cxSetResourceString(@sdxPureColorNavy, '藏青');
  ////'Navy');
  cxSetResourceString(@sdxPureColorSkyBlue, '天蓝');
  ////'Sky Blue');
  cxSetResourceString(@sdxPureColorGray, '灰');
  ////'Gray');
  cxSetResourceString(@sdxPureColorMedGray, '中灰');
  ////'Medium Gray');
  cxSetResourceString(@sdxPureColorSilver, '银');
  ////'Silver');
  cxSetResourceString(@sdxPureColorMaroon, '茶色');
  ////'Maroon');
  cxSetResourceString(@sdxPureColorPurple, '紫');
  ////'Purple');
  cxSetResourceString(@sdxPureColorFuchsia, '紫红');
  ////'Fuchsia');
  cxSetResourceString(@sdxPureColorCream, '米色');
  ////'Cream');

  cxSetResourceString(@sdxBrushStyleSolid, '固体');
  ////'Solid');
  cxSetResourceString(@sdxBrushStyleClear, '清除');
  ////'Clear');
  cxSetResourceString(@sdxBrushStyleHorizontal, '水平');
  ////'Horizontal');
  cxSetResourceString(@sdxBrushStyleVertical, '垂直');
  ////'Vertical');
  cxSetResourceString(@sdxBrushStyleFDiagonal, 'F斜纹');
  ////'FDiagonal');
  cxSetResourceString(@sdxBrushStyleBDiagonal, 'B斜纹');
  ////'BDiagonal');
  cxSetResourceString(@sdxBrushStyleCross, '交叉');
  ////'Cross');
  cxSetResourceString(@sdxBrushStyleDiagCross, '反交叉');
  ////'DiagCross');

  //cxFilterConsts.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // base operators
  cxSetResourceString(@cxSFilterOperatorEqual, '等于');
  //'equals');
  cxSetResourceString(@cxSFilterOperatorNotEqual, '不等于');
  //'does not equal');
  cxSetResourceString(@cxSFilterOperatorLess, '小于');
  //'is less than');
  cxSetResourceString(@cxSFilterOperatorLessEqual, '小于等于');
  //'is less than or equal to');
  cxSetResourceString(@cxSFilterOperatorGreater, '大于');
  //'is greater than');
  cxSetResourceString(@cxSFilterOperatorGreaterEqual, '大于等于');
  //'is greater than or equal to');
  cxSetResourceString(@cxSFilterOperatorLike, '相似');
  //'like');
  cxSetResourceString(@cxSFilterOperatorNotLike, '不相似');
  //'not like');
  cxSetResourceString(@cxSFilterOperatorBetween, '在...之间');
  //'between');
  cxSetResourceString(@cxSFilterOperatorNotBetween, '不在...之间');
  //'not between');
  cxSetResourceString(@cxSFilterOperatorInList, '包含');
  //'in');
  cxSetResourceString(@cxSFilterOperatorNotInList, '不包含');
  //'not in');

  cxSetResourceString(@cxSFilterOperatorYesterday, '昨天');
  //'is yesterday');
  cxSetResourceString(@cxSFilterOperatorToday, '今天');
  //'is today');
  cxSetResourceString(@cxSFilterOperatorTomorrow, '明天');
  //'is tomorrow');

  cxSetResourceString(@cxSFilterOperatorLastWeek, '前一周');
  //'is last week');
  cxSetResourceString(@cxSFilterOperatorLastMonth, '前一月');
  //'is last month');
  cxSetResourceString(@cxSFilterOperatorLastYear, '前一年');
  //'is last year');

  cxSetResourceString(@cxSFilterOperatorThisWeek, '本周');
  //'is this week');
  cxSetResourceString(@cxSFilterOperatorThisMonth, '本月');
  //'is this month');
  cxSetResourceString(@cxSFilterOperatorThisYear, '本年');
  //'is this year');

  cxSetResourceString(@cxSFilterOperatorNextWeek, '下一周');
  //'is next week');
  cxSetResourceString(@cxSFilterOperatorNextMonth, '下一月');
  //'is next month');
  cxSetResourceString(@cxSFilterOperatorNextYear, '下一年');
  //'is next year');

  cxSetResourceString(@cxSFilterAndCaption, '并且');
  //'and');
  cxSetResourceString(@cxSFilterOrCaption, '或者');
  //'or');
  cxSetResourceString(@cxSFilterNotCaption, '非');
  //'not');
  cxSetResourceString(@cxSFilterBlankCaption, '空');
  //'blank');

  // derived
  cxSetResourceString(@cxSFilterOperatorIsNull, '为空');
  //'is blank');
  cxSetResourceString(@cxSFilterOperatorIsNotNull, '不为空');
  //'is not blank');
  cxSetResourceString(@cxSFilterOperatorBeginsWith, '起始于');
  //'begins with');
  cxSetResourceString(@cxSFilterOperatorDoesNotBeginWith, '不起始于');
  //'does not begin with');
  cxSetResourceString(@cxSFilterOperatorEndsWith, '结束于');
  //'ends with');
  cxSetResourceString(@cxSFilterOperatorDoesNotEndWith, '不结束于');
  //'does not end with');
  cxSetResourceString(@cxSFilterOperatorContains, '包含');
  //'contains');
  cxSetResourceString(@cxSFilterOperatorDoesNotContain, '不包含');
  //'does not contain');
  // filter listbox's values
  cxSetResourceString(@cxSFilterBoxAllCaption, '(全部显示)');
  //'(All)');
  cxSetResourceString(@cxSFilterBoxCustomCaption, '(定制过滤...)');
  //'(Custom...)');
  cxSetResourceString(@cxSFilterBoxBlanksCaption, '(为空)');
  //'(Blanks)');
  cxSetResourceString(@cxSFilterBoxNonBlanksCaption, '(不为空)');
  //'(NonBlanks)');

  //cxDataConsts.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@cxSDataReadError, '输入流错误');
  ////'Stream read error');
  cxSetResourceString(@cxSDataWriteError, '输出流错误');
  ////'Stream write error');
  cxSetResourceString(@cxSDataItemExistError, '项目已经存在');
  ////'Item already exists');
  cxSetResourceString(@cxSDataRecordIndexError, '记录索引超出范围');
  ////'RecordIndex out of range');
  cxSetResourceString(@cxSDataItemIndexError, '项目索引超出范围');
  ////'ItemIndex out of range');
  cxSetResourceString(@cxSDataProviderModeError, '数据提供者不提供该操作');
  ////'This operation is not supported in provider mode');
  cxSetResourceString(@cxSDataInvalidStreamFormat, '错误的流格式');
  ////'Invalid stream format');
  cxSetResourceString(@cxSDataRowIndexError, '行索引超出范围');
  ////'RowIndex out of range');
  //  cxSetResourceString(@cxSDataRelationItemExistError,'关联项目不存在');
  ////'Relation Item already exists');
  //  cxSetResourceString(@cxSDataRelationCircularReference,'细节数据控制器循环引用');
  ////'Circular Reference on Detail DataController');
  //  cxSetResourceString(@cxSDataRelationMultiReferenceError,'引用细节数据控制器已经存在');
  ////'Reference on Detail DataController already exists');
  cxSetResourceString(@cxSDataCustomDataSourceInvalidCompare, 'GetInfoForCompare 没有实现');
  ////'GetInfoForCompare not implemented');

  //  cxSDBDataSetNil,'数据集为空');
  ////'DataSet is nil');
  cxSetResourceString(@cxSDBDetailFilterControllerNotFound, '细节数据控制器没有发现');
  ////'DetailFilterController not found');
  cxSetResourceString(@cxSDBNotInGridMode, '数据控制器不在表格(Grid)模式e');
  ////'DataController not in GridMode');
  cxSetResourceString(@cxSDBKeyFieldNotFound, 'Key Field not found');

  //cxFilterControlStrs.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // cxFilterBoolOperator
  cxSetResourceString(@cxSFilterBoolOperatorAnd, '并且'); // all
  //'AND');        // all
  cxSetResourceString(@cxSFilterBoolOperatorOr, '或者'); // any
  //'OR');          // any
  cxSetResourceString(@cxSFilterBoolOperatorNotAnd, '非并且'); // not all
  //'NOT AND'); // not all
  cxSetResourceString(@cxSFilterBoolOperatorNotOr, '非或者'); // not any
  //'NOT OR');   // not any
  //
  cxSetResourceString(@cxSFilterRootButtonCaption, '过滤');
  //'Filter');
  cxSetResourceString(@cxSFilterAddCondition, '添加条件(&C)');
  //'Add &Condition');
  cxSetResourceString(@cxSFilterAddGroup, '添加组(&G)');
  //'Add &Group');
  cxSetResourceString(@cxSFilterRemoveRow, '删除行(&R)');
  //'&Remove Row');
  cxSetResourceString(@cxSFilterClearAll, '清除(&A)');
  //'Clear &All');
  cxSetResourceString(@cxSFilterFooterAddCondition, '按此按钮增加新条件');
  //'press the button to add a new condition');

  cxSetResourceString(@cxSFilterGroupCaption, '使用下面的条件');

  //'applies to the following conditions');
  cxSetResourceString(@cxSFilterRootGroupCaption, '<根>');
  //'<root>');
  cxSetResourceString(@cxSFilterControlNullString, '<空>');
  //'<empty>');

  cxSetResourceString(@cxSFilterErrorBuilding, '不能从源建立过滤');
  //'Can''t build filter from source');

  //FilterDialog
  cxSetResourceString(@cxSFilterDialogCaption, '定制过滤');
  //'Custom Filter');
  cxSetResourceString(@cxSFilterDialogInvalidValue, '输入值非法');
  //'Invalid value');
  cxSetResourceString(@cxSFilterDialogUse, '使用');
  //'Use');
  cxSetResourceString(@cxSFilterDialogSingleCharacter, '表示任何单个字符');
  //'to represent any single character');
  cxSetResourceString(@cxSFilterDialogCharactersSeries, '表示任意字符');
  //'to represent any series of characters');
  cxSetResourceString(@cxSFilterDialogOperationAnd, '并且');
  //'AND');
  cxSetResourceString(@cxSFilterDialogOperationOr, '或者');
  //'OR');
  cxSetResourceString(@cxSFilterDialogRows, '显示条件行:');
  //'Show rows where:');

  // FilterControlDialog
  cxSetResourceString(@cxSFilterControlDialogCaption, '过滤生成器');
  //'Filter builder');
  cxSetResourceString(@cxSFilterControlDialogNewFile, '未命名.flt');
  //'untitled.flt');
  cxSetResourceString(@cxSFilterControlDialogOpenDialogCaption, '打开一个已存文件');
  cxSetResourceString(@cxSFilterControlDialogSaveDialogCaption, '保存当前活动文件'); //'Save the active filter to file');
  cxSetResourceString(@cxSFilterControlDialogActionSaveCaption, '另存');
  cxSetResourceString(@cxSFilterControlDialogActionOpenCaption, '打开');
  cxSetResourceString(@cxSFilterControlDialogActionApplyCaption, '应用');
  cxSetResourceString(@cxSFilterControlDialogActionOkCaption, '确定');
  //'OK');
  cxSetResourceString(@cxSFilterControlDialogActionCancelCaption, '取消');
  cxSetResourceString(@cxSFilterControlDialogFileExt, 'flt');
  //'flt');
  cxSetResourceString(@cxSFilterControlDialogFileFilter, '过滤文件 (*.flt)|*.flt');
                                                                                
  //cxEditConsts.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@cxSEditButtonCancel, '取消');
  //sdl//'Cancel'
  cxSetResourceString(@cxSEditButtonOK, '确定');
  //sdl//'OK'
  cxSetResourceString(@cxSEditDateConvertError, 'Could not convert to date');
  cxSetResourceString(@cxSEditInvalidRepositoryItem, '此仓库项目不可接收');
  ////'The repository item is not acceptable');
  cxSetResourceString(@cxSEditNumericValueConvertError, '不能转换到数字');
  ////'Could not convert to numeric value');
  cxSetResourceString(@cxSEditPopupCircularReferencingError, '不允许循环引用');
  ////'Circular referencing is not allowed');
  cxSetResourceString(@cxSEditPostError, '当提交编辑值时发生错误');
  ////'An error occured during posting edit value');
  cxSetResourceString(@cxSEditTimeConvertError, '不能转换到时间');
  ////'Could not convert to time');
  cxSetResourceString(@cxSEditValidateErrorText, '不正确的输入值. 使用ESC键放弃改变');
  ////'Invalid input value. Use escape key to abandon changes');
  cxSetResourceString(@cxSEditValueOutOfBounds, '值超出范围');
  ////'Value out of bounds');

  // TODO
  cxSetResourceString(@cxSEditCheckBoxChecked, '是');
  ////'True');
  cxSetResourceString(@cxSEditCheckBoxGrayed, '');
  ////'');
  cxSetResourceString(@cxSEditCheckBoxUnchecked, '否');
  ////'False');
  cxSetResourceString(@cxSRadioGroupDefaultCaption, '');
  ////'');

  cxSetResourceString(@cxSTextTrue, '是');
  ////'True');
  cxSetResourceString(@cxSTextFalse, '否');
  ////'False');

  // blob
  cxSetResourceString(@cxSBlobButtonOK, '确定(&O)');
  ////'&OK');
  cxSetResourceString(@cxSBlobButtonCancel, '取消(&C)');
  ////'&Cancel');
  cxSetResourceString(@cxSBlobButtonClose, '关闭(&C)');
  ////'&Close');
  cxSetResourceString(@cxSBlobMemo, '(文本)');
  ////'(MEMO)');
  cxSetResourceString(@cxSBlobMemoEmpty, '(空文本)');
  ////'(memo)');
  cxSetResourceString(@cxSBlobPicture, '(图像)');
  ////'(PICTURE)');
  cxSetResourceString(@cxSBlobPictureEmpty, '(空图像)');
  ////'(picture)');

  // popup menu items
  cxSetResourceString(@cxSMenuItemCaptionCut, '剪切(&T)');
  ////'Cu&t');
  cxSetResourceString(@cxSMenuItemCaptionCopy, '复制(&C)');
  ////'&Copy');
  cxSetResourceString(@cxSMenuItemCaptionPaste, '粘贴(&P)');
  ////'&Paste');
  cxSetResourceString(@cxSMenuItemCaptionDelete, '删除(&D)');
  ////'&Delete');
  cxSetResourceString(@cxSMenuItemCaptionLoad, '装入(&L)...');
  ////'&Load...');
  cxSetResourceString(@cxSMenuItemCaptionSave, '另存为(&A)...');
  ////'Save &As...');

  // date
  cxSetResourceString(@cxSDatePopupClear, '清除');
  ////'Clear');
  cxSetResourceString(@cxSDatePopupNow, '现在');
  cxSetResourceString(@cxSDatePopupOK, '确定');
  cxSetResourceString(@cxSDatePopupToday, '今天');
  ////'Today');
  cxSetResourceString(@cxSDateError, '非法日期');
  ////'Invalid Date');
  // smart input consts
  cxSetResourceString(@cxSDateToday, '今天');
  ////'today');
  cxSetResourceString(@cxSDateYesterday, '昨天');
  ////'yesterday');
  cxSetResourceString(@cxSDateTomorrow, '明天');
  ////'tomorrow');
  cxSetResourceString(@cxSDateSunday, '日');
  ////'Sunday');
  cxSetResourceString(@cxSDateMonday, '一');
  ////'Monday');
  cxSetResourceString(@cxSDateTuesday, '二');
  ////'Tuesday');
  cxSetResourceString(@cxSDateWednesday, '三');
  ////'Wednesday');
  cxSetResourceString(@cxSDateThursday, '四');
  ////'Thursday');
  cxSetResourceString(@cxSDateFriday, '五');
  ////'Friday');
  cxSetResourceString(@cxSDateSaturday, '六');
  ////'Saturday');
  cxSetResourceString(@cxSDateFirst, '第一');
  ////'first');
  cxSetResourceString(@cxSDateSecond, '第二');
  ////'second');
  cxSetResourceString(@cxSDateThird, '第三');
  ////'third');
  cxSetResourceString(@cxSDateFourth, '第四');
  ////'fourth');
  cxSetResourceString(@cxSDateFifth, '第五');
  ////'fifth');
  cxSetResourceString(@cxSDateSixth, '第六');
  ////'sixth');
  cxSetResourceString(@cxSDateSeventh, '第七');
  ////'seventh');
  cxSetResourceString(@cxSDateBOM, '月初');
  ////'bom');
  cxSetResourceString(@cxSDateEOM, '月末');
  ////'eom');
  cxSetResourceString(@cxSDateNow, '现在');
  ////'now');

  // calculator
  cxSetResourceString(@scxSCalcError, '错误');
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

  cxSetResourceString(@scxRegExprLine, '行');
  ////'Line');
  cxSetResourceString(@scxRegExprChar, '字符');
  ////'Char');
  cxSetResourceString(@scxRegExprNotAssignedSourceStream, '此源流没有被赋值');
  ////'The source stream is not assigned');
  cxSetResourceString(@scxRegExprEmptySourceStream, '此源流是空的');
  ////'The source stream is empty');
  cxSetResourceString(@scxRegExprCantUsePlusQuantifier, '符号 ''+'' 不能应用到这');
  ////'The ''+'' quantifier cannot be applied here');
  cxSetResourceString(@scxRegExprCantUseStarQuantifier, '符号 ''*'' 不能应用到这');
  ////'The ''*'' quantifier cannot be applied here');
  cxSetResourceString(@scxRegExprCantCreateEmptyAlt, '二中择一不能为空');
  ////'The alternative should not be empty');
  cxSetResourceString(@scxRegExprCantCreateEmptyBlock, '此块应该为空');
  ////'The block should not be empty');
  cxSetResourceString(@scxRegExprIllegalSymbol, '不合规定的 ''%s''');
  ////'Illegal ''%s''');
  cxSetResourceString(@scxRegExprIllegalQuantifier, '不合规定的量词 ''%s''');
  ////'Illegal quantifier ''%s''');
  cxSetResourceString(@scxRegExprNotSupportQuantifier, '此参数量词不支持');
  ////'The parameter quantifiers are not supported');
  cxSetResourceString(@scxRegExprIllegalIntegerValue, '不合法的整数值');
  ////'Illegal integer value');
  cxSetResourceString(@scxRegExprTooBigReferenceNumber, '引用数太大');
  ////'Too big reference number');
  cxSetResourceString(@scxRegExprCantCreateEmptyEnum, '不能创建空的枚举值');
  ////'Can''t create empty enumeration');
  cxSetResourceString(@scxRegExprSubrangeOrder, '子串的开始字符位置不能超出结束字符位置');
  ////'The starting character of the subrange must be less than the finishing one');
  cxSetResourceString(@scxRegExprHexNumberExpected0, '期待十六进制数');
  ////'Hexadecimal number expected');
  cxSetResourceString(@scxRegExprHexNumberExpected, '期待十六进制数的位置发现了 ''%s'' ');
  ////'Hexadecimal number expected but ''%s'' found');
  cxSetResourceString(@scxRegExprMissing, '缺少 ''%s''');
  ////'Missing ''%s''');
  cxSetResourceString(@scxRegExprUnnecessary, '不必要的 ''%s''');
  ////'Unnecessary ''%s''');
  cxSetResourceString(@scxRegExprIncorrectSpace, '在 ''\'' 后不能出现空格字符');
  ////'The space character is not allowed after ''\''');
  cxSetResourceString(@scxRegExprNotCompiled, '规则表达式不能编译');
  ////'Regular expression is not compiled');
  cxSetResourceString(@scxRegExprIncorrectParameterQuantifier, '错误的参数');
  ////'Incorrect parameter quantifier');
  cxSetResourceString(@scxRegExprCantUseParameterQuantifier, '此参数不能应用在此处');
  ////'The parameter quantifier cannot be applied here');

  cxSetResourceString(@scxMaskEditRegExprError, '规则表达式错误:');
  ////'Regular expression errors:');
  cxSetResourceString(@scxMaskEditInvalidEditValue, '编辑值非法');
  ////'The edit value is invalid');
  cxSetResourceString(@scxMaskEditNoMask, '没有');
  ////'None');
  cxSetResourceString(@scxMaskEditIllegalFileFormat, '文件格式非法');
  ////'Illegal file format');
  cxSetResourceString(@scxMaskEditEmptyMaskCollectionFile, '掩码格式文件为空');
  ////'The mask collection file is empty');
  cxSetResourceString(@scxMaskEditMaskCollectionFiles, '掩码格式文件');
  ////'Mask collection files');
  cxSetResourceString(@cxSSpinEditInvalidNumericValue, 'Invalid numeric value');

  //dxPSRes.pas
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  cxSetResourceString(@sdxBtnOK,'确定(&O)');
  ////'OK');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxBtnOKAccelerated,'确定(&O');
  ////'&OK');                                                                                                                                                                                                       
  cxSetResourceString(@sdxBtnCancel,'取消');
  ////'Cancel');                                                                                                                                                                                                              
  cxSetResourceString(@sdxBtnClose,'关闭');
  ////'Close');                                                                                                                                                                                                                
  cxSetResourceString(@sdxBtnApply,'应用(&A)');
  ////'&Apply');                                                                                                                                                                                                           
  cxSetResourceString(@sdxBtnHelp,'帮助(&H)');
  ////'&Help');                                                                                                                                                                                                             
  cxSetResourceString(@sdxBtnFix,'调整(&F)');
  ////'&Fix');                                                                                                                                                                                                               
  cxSetResourceString(@sdxBtnNew,'新建(&N)...');
  ////'&New...');                                                                                                                                                                                                         
  cxSetResourceString(@sdxBtnIgnore,'忽略(&I)');
  ////'&Ignore');                                                                                                                                                                                                         
  cxSetResourceString(@sdxBtnYes,'是(&Y)');
  ////'&Yes');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnNo,'否(&N)');
  ////'&No');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxBtnEdit,'编辑(&E)...');
  ////'&Edit...');                                                                                                                                                                                                       
  cxSetResourceString(@sdxBtnReset,'复位(&R)');
  ////'&Reset');                                                                                                                                                                                                           
  cxSetResourceString(@sdxBtnAdd,'增加(&A');
  ////'&Add');                                                                                                                                                                                                                
  cxSetResourceString(@sdxBtnAddComposition,'增加布局(&C)');
  ////'Add &Composition');                                                                                                                                                                                    
  cxSetResourceString(@sdxBtnDefault,'默认(&D)...');
  ////'&Default...');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnDelete,'删除(&D)...');
  ////'&Delete...');                                                                                                                                                                                                   
  cxSetResourceString(@sdxBtnDescription,'描述(&D)...');
  ////'&Description...');                                                                                                                                                                                         
  cxSetResourceString(@sdxBtnCopy,'复制(&C)...');
  ////'&Copy...');                                                                                                                                                                                                       
  cxSetResourceString(@sdxBtnYesToAll,'全部是(&A)');
  ////'Yes To &All');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnRestoreDefaults,'恢复默认值(&R)');
  ////'&Restore Defaults');                                                                                                                                                                                
  cxSetResourceString(@sdxBtnRestoreOriginal,'还原(&O)');
  ////'Restore &Original');                                                                                                                                                                                      
  cxSetResourceString(@sdxBtnTitleProperties,'标题属性...');
  ////'Title Properties...');                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnProperties,'属性(&R)...');
  ////'P&roperties...');                                                                                                                                                                                           
  cxSetResourceString(@sdxBtnNetwork,'网络(&W)...');
  ////'Net&work...');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnBrowse,'浏览(&B)...');
  ////'&Browse...');                                                                                                                                                                                                   
  cxSetResourceString(@sdxBtnPageSetup,'页面设置(&G)...');
  ////'Pa&ge Setup...');                                                                                                                                                                                        
  cxSetResourceString(@sdxBtnPrintPreview,'打印预览(&V)...');
  ////'Print Pre&view...');                                                                                                                                                                                  
  cxSetResourceString(@sdxBtnPreview,'预览(&V)...');
  ////'Pre&view...');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnPrint,'打印...');
  ////'Print...');                                                                                                                                                                                                          
  cxSetResourceString(@sdxBtnOptions,'选项(&O)...');
  ////'&Options...');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnStyleOptions,'样式选项...');
  ////'Style Options...');                                                                                                                                                                                       
  cxSetResourceString(@sdxBtnDefinePrintStyles,'定义样式(&D)...');
  ////'&Define Styles...');                                                                                                                                                                             
  cxSetResourceString(@sdxBtnPrintStyles,'打印样式');
  ////'Print Styles');                                                                                                                                                                                               
  cxSetResourceString(@sdxBtnBackground,'背景');
  ////'Background');                                                                                                                                                                                                      
  cxSetResourceString(@sdxBtnShowToolBar,'显示工具栏(&T)');
  ////'Show &ToolBar');                                                                                                                                                                                        
  cxSetResourceString(@sdxBtnDesign,'设计(&E)...');
  ////'D&esign...');                                                                                                                                                                                                   
  cxSetResourceString(@sdxBtnMoveUp,'上移(&U)');
  ////'Move &Up');                                                                                                                                                                                                        
  cxSetResourceString(@sdxBtnMoveDown,'下移(&N)');
  ////'Move Dow&n'); 

  cxSetResourceString(@sdxBtnMoreColors,'其他颜色(&M)...');
  ////'&More Colors...');                                                                                                                                                                                      
  cxSetResourceString(@sdxBtnFillEffects,'填充效果(&F)...');
  ////'&Fill Effects...');                                                                                                                                                                                    
  cxSetResourceString(@sdxBtnNoFill,'不填充');
  ////'&No Fill');                                                                                                                                                                                                          
  cxSetResourceString(@sdxBtnAutomatic,'自动(&A)');
  ////'&Automatic');                                                                                                                                                                                                   
  cxSetResourceString(@sdxBtnNone,'无(&N)');
  ////'&None'); 

  cxSetResourceString(@sdxBtnOtherTexture,'其它纹理(&X)...');
  ////'Other Te&xture...');                                                                                                                                                                                  
  cxSetResourceString(@sdxBtnInvertColors,'反转颜色(&N)');
  ////'I&nvert Colors');                                                                                                                                                                                        
  cxSetResourceString(@sdxBtnSelectPicture,'选择图片(&L)...');
  ////'Se&lect Picture...'); 

  cxSetResourceString(@sdxEditReports,'编辑报表');
  ////'Edit Reports');                                                                                                                                                                                                  
  cxSetResourceString(@sdxComposition,'布局');
  ////'Composition');                                                                                                                                                                                                       
  cxSetResourceString(@sdxReportTitleDlgCaption,'报表标题');
  ////'Report Title');                                                                                                                                                                                        
  cxSetResourceString(@sdxMode,'模式(&M):');
  ////'&Mode:');                                                                                                                                                                                                              
  cxSetResourceString(@sdxText,'本文(&T)');
  ////'&Text');                                                                                                                                                                                                                
  cxSetResourceString(@sdxProperties,'属性(&P)');
  ////'&Properties');                                                                                                                                                                                                    
  cxSetResourceString(@sdxAdjustOnScale,'适合页面(&A)');
  ////'&Adjust on Scale');                                                                                                                                                                                        
  cxSetResourceString(@sdxTitleModeNone,'无');
  ////'None');                                                                                                                                                                                                              
  cxSetResourceString(@sdxTitleModeOnEveryTopPage,'在每张顶页');
  ////'On Every Top Page');                                                                                                                                                                               
  cxSetResourceString(@sdxTitleModeOnFirstPage,'在第一页');
  ////'On First Page'); 

  cxSetResourceString(@sdxEditDescription,'编辑描述');
  ////'Edit Description');                                                                                                                                                                                          
  cxSetResourceString(@sdxRename,'重命名(&M)');
  ////'Rena&me');                                                                                                                                                                                                          
  cxSetResourceString(@sdxSelectAll,'全选');
  ////'&Select All'); 
  
  cxSetResourceString(@sdxAddReport,'增加报表');
  ////'Add Report');                                                                                                                                                                                                      
  cxSetResourceString(@sdxAddAndDesignReport,'增加并设计报表(&D)...');
  ////'Add and D&esign Report...');                                                                                                                                                                 
  cxSetResourceString(@sdxNewCompositionCaption,'新建布局');
  ////'New Composition');                                                                                                                                                                                     
  cxSetResourceString(@sdxName,'名字(&N):');
  ////'&Name:');                                                                                                                                                                                                              
  cxSetResourceString(@sdxCaption,'标题(&C):');
  ////'&Caption:');                                                                                                                                                                                                        
  cxSetResourceString(@sdxAvailableSources,'可用的源(&A)');
  ////'&Available Source(s)');                                                                                                                                                                                 
  cxSetResourceString(@sdxOnlyComponentsInActiveForm,'只显示当前表单的组件');
  ////'Only Components in Active &Form');                                                                                                                                                    
  cxSetResourceString(@sdxOnlyComponentsWithoutLinks,'只显示除现有报表链接以外的组件');
  ////'Only Components &without Existing ReportLinks');                                                                                                                            
  cxSetResourceString(@sdxItemName,'名称');
  ////'Name');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxItemDescription,'描述');
  ////'Description');
    
  cxSetResourceString(@sdxConfirmDeleteItem,'要删除下一个项目： %s 吗?');
  ////'Do you want to delete next items: %s ?');                                                                                                                                                 
  cxSetResourceString(@sdxAddItemsToComposition,'增加项目到布局');
  ////'Add Items to Composition');                                                                                                                                                                      
  cxSetResourceString(@sdxHideAlreadyIncludedItems,'隐藏已包含项目');
  ////'Hide Already &Included Items');                                                                                                                                                               
  cxSetResourceString(@sdxAvailableItems,'可用项目(&I)');
  ////'A&vailable Items');                                                                                                                                                                                       
  cxSetResourceString(@sdxItems,'项目(&I)');
  ////'&Items');                                                                                                                                                                                                              
  cxSetResourceString(@sdxEnable,'允许(&E)');
  ////'&Enable');                                                                                                                                                                                                            
  cxSetResourceString(@sdxOptions,'选项');
  ////'Options');                                                                                                                                                                                                               
  cxSetResourceString(@sdxShow,'显示');
  ////'Show');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxPaintItemsGraphics,'绘制项目图示(&P)');
  ////'&Paint Item Graphics');                                                                                                                                                                           
  cxSetResourceString(@sdxDescription,'描述:');
  ////'&Description:');

  cxSetResourceString(@sdxNewReport,'新报表');
  ////'NewReport');
    
  cxSetResourceString(@sdxOnlySelected,'只是选定的(&S)');
  ////'Only &Selected');                                                                                                                                                                                         
  cxSetResourceString(@sdxExtendedSelect,'扩展选定的(&E)');
  ////'&Extended Select');                                                                                                                                                                                     
  cxSetResourceString(@sdxIncludeFixed,'包含固定区(&I)');
  ////'&Include Fixed');

  cxSetResourceString(@sdxFonts,'字体');
  ////'Fonts');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxBtnFont,'字体(&N)...');
  ////'Fo&nt...');                                                                                                                                                                                                       
  cxSetResourceString(@sdxBtnEvenFont,'偶数行字体(&V)...');
  ////'E&ven Font...');                                                                                                                                                                                        
  cxSetResourceString(@sdxBtnOddFont,'奇数行字体(&N)...');
  ////'Odd Fo&nt...');                                                                                                                                                                                          
  cxSetResourceString(@sdxBtnFixedFont,'固定区字体(&I)...');
  ////'F&ixed Font...');                                                                                                                                                                                      
  cxSetResourceString(@sdxBtnGroupFont,'组字体(&P)...');
  ////'Grou&p Font...');                                                                                                                                                                                          
  cxSetResourceString(@sdxBtnChangeFont,'更换字体(&N)...');
  ////'Change Fo&nt...');

  cxSetResourceString(@sdxFont,'字体');
  ////'Font');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxOddFont,'奇数行字体');
  ////'Odd Font');                                                                                                                                                                                                        
  cxSetResourceString(@sdxEvenFont,'偶数行字体');
  ////'Even Font');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPreviewFont,'预览字体');
  ////'Preview Font');                                                                                                                                                                                                  
  cxSetResourceString(@sdxCaptionNodeFont,'层次标题字体');
  ////'Level Caption Font');                                                                                                                                                                                    
  cxSetResourceString(@sdxGroupNodeFont,'组节点字体');
  ////'Group Node Font');                                                                                                                                                                                           
  cxSetResourceString(@sdxGroupFooterFont,'组脚字体');
  ////'Group Footer Font');                                                                                                                                                                                         
  cxSetResourceString(@sdxHeaderFont,'页眉字体');
  ////'Header Font');                                                                                                                                                                                                    
  cxSetResourceString(@sdxFooterFont,'页脚字体');
  ////'Footer Font');                                                                                                                                                                                                    
  cxSetResourceString(@sdxBandFont,'带区字体');
  ////'Band Font');

  cxSetResourceString(@sdxTransparent,'透明(&T)');
  ////'&Transparent');                                                                                                                                                                                                  
  cxSetResourceString(@sdxFixedTransparent,'透明(&X)');
  ////'Fi&xed Transparent');                                                                                                                                                                                       
  cxSetResourceString(@sdxCaptionTransparent,'标题透明');
  ////'Caption Transparent');                                                                                                                                                                                    
  cxSetResourceString(@sdxGroupTransparent,'组透明');
  ////'Group Transparent'); 

  cxSetResourceString(@sdxGraphicAsTextValue,'(图像)');
  ////'(GRAPHIC)');                                                                                                                                                                                                
  cxSetResourceString(@sdxColors,'颜色');
  ////'Colors');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxColor,'颜色(&L):');
  ////'Co&lor:');                                                                                                                                                                                                            
  cxSetResourceString(@sdxOddColor,'奇数行颜色(&L):');
  ////'Odd Co&lor:');                                                                                                                                                                                               
  cxSetResourceString(@sdxEvenColor,'偶数行颜色(&V):');
  ////'E&ven Color:');                                                                                                                                                                                             
  cxSetResourceString(@sdxPreviewColor,'预览颜色(&P):');
  ////'&Preview Color:');                                                                                                                                                                                         
  cxSetResourceString(@sdxBandColor,'带区颜色(&B):');
  ////'&Band Color:');                                                                                                                                                                                               
  cxSetResourceString(@sdxLevelCaptionColor,'层次标题颜色(&V):');
  ////'Le&vel Caption Color:');                                                                                                                                                                          
  cxSetResourceString(@sdxHeaderColor,'标题颜色(&E):');
  ////'H&eader Color:');                                                                                                                                                                                           
  cxSetResourceString(@sdxGroupNodeColor,'组节点颜色(&N):');
  ////'Group &Node Color:');                                                                                                                                                                                  
  cxSetResourceString(@sdxGroupFooterColor,'组脚颜色(&G):');
  ////'&Group Footer Color:');                                                                                                                                                                                
  cxSetResourceString(@sdxFooterColor,'页脚颜色(&T):');
  ////'Foo&ter Color:');                                                                                                                                                                                           
  cxSetResourceString(@sdxFixedColor,'固定颜色(&I):');
  ////'F&ixed Color:');                                                                                                                                                                                             
  cxSetResourceString(@sdxGroupColor,'组颜色(&I):');
  ////'Grou&p Color:');                                                                                                                                                                                               
  cxSetResourceString(@sdxCaptionColor,'标题颜色:');
  ////'Caption Color:');                                                                                                                                                                                              
  cxSetResourceString(@sdxGridLinesColor,'网格线颜色(&D):');
  ////'Gri&d Line Color:');

  cxSetResourceString(@sdxBands,'带区(&B)');
  ////'&Bands');                                                                                                                                                                                                              
  cxSetResourceString(@sdxLevelCaptions,'层次标题(&C)');
  ////'Levels &Caption');                                                                                                                                                                                         
  cxSetResourceString(@sdxHeaders,'页眉(&E)');
  ////'H&eaders');                                                                                                                                                                                                          
  cxSetResourceString(@sdxFooters,'页脚(&R)');
  ////'Foote&rs');                                                                                                                                                                                                          
  cxSetResourceString(@sdxGroupFooters,'组脚(&G)');
  ////'&Group Footers');                                                                                                                                                                                               
  cxSetResourceString(@sdxPreview,'预览(&W)');
  ////'Previe&w');                                                                                                                                                                                                          
  cxSetResourceString(@sdxPreviewLineCount,'预览行数(&T):');
  ////'Preview Line Coun&t:');                                                                                                                                                                                
  cxSetResourceString(@sdxAutoCalcPreviewLineCount,'自动计算预览行数(&U)');
  ////'A&uto Calculate Preview Lines');

  cxSetResourceString(@sdxGrid,'网格(&D)');
  ////'Grid Lines');                                                                                                                                                                                                           
  cxSetResourceString(@sdxNodesGrid,'节点网格(&N)');
  ////'Node Grid Lines');                                                                                                                                                                                             
  cxSetResourceString(@sdxGroupFooterGrid,'组脚网格(&P)');
  ////'GroupFooter Grid Lines');                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxStateImages,'状态图像(&S)');
  ////'&State Images');                                                                                                                                                                                             
  cxSetResourceString(@sdxImages,'图象(&I)');
  ////'&Images'); 

  cxSetResourceString(@sdxTextAlign,'文本排列(&A)');
  ////'Text&Align');                                                                                                                                                                                                  
  cxSetResourceString(@sdxTextAlignHorz,'水平(&Z)');
  ////'Hori&zontally');                                                                                                                                                                                               
  cxSetResourceString(@sdxTextAlignVert,'垂直(&V)');
  ////'&Vertically');                                                                                                                                                                                                 
  cxSetResourceString(@sdxTextAlignLeft,'靠左');
  ////'Left');                                                                                                                                                                                                            
  cxSetResourceString(@sdxTextAlignCenter,'居中');
  ////'Center');                                                                                                                                                                                                        
  cxSetResourceString(@sdxTextAlignRight,'靠右');
  ////'Right');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTextAlignTop,'顶部');
  ////'Top');                                                                                                                                                                                                              
  cxSetResourceString(@sdxTextAlignVCenter,'居中');
  ////'Center');                                                                                                                                                                                                       
  cxSetResourceString(@sdxTextAlignBottom,'底部');
  ////'Bottom');                                                                                                                                                                                                        
  cxSetResourceString(@sdxBorderLines,'边框线条(&B)');
  ////'&Border');                                                                                                                                                                                                   
  cxSetResourceString(@sdxHorzLines,'水平线(&Z)');
  ////'Hori&zontal Lines');                                                                                                                                                                                             
  cxSetResourceString(@sdxVertLines,'垂直线(&V)');
  ////'&Vertical Lines');                                                                                                                                                                                               
  cxSetResourceString(@sdxFixedHorzLines,'固定水平线(&X)');
  ////'Fi&xed Horizontal Lines');                                                                                                                                                                              
  cxSetResourceString(@sdxFixedVertLines,'固定垂直线(&D)');
  ////'Fixe&d Vertical Lines');                                                                                                                                                                                
  cxSetResourceString(@sdxFlatCheckMarks,'平面检查框(&L)');
  ////'F&lat CheckMarks');                                                                                                                                                                                     
  cxSetResourceString(@sdxCheckMarksAsText,'用文本显示检查框(&D)');
  ////'&Display CheckMarks as Text');

  cxSetResourceString(@sdxRowAutoHeight,'自动计算行高(&W)');
  ////'Ro&w AutoHeight');                                                                                                                                                                                     
  cxSetResourceString(@sdxEndEllipsis,'结束省略符(&E)');
  ////'&EndEllipsis');                                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxDrawBorder,'绘制边框(&D)');
  ////'&Draw Border');                                                                                                                                                                                               
  cxSetResourceString(@sdxFullExpand,'完全展开(&E)');
  ////'Full &Expand');                                                                                                                                                                                               
  cxSetResourceString(@sdxBorderColor,'边框颜色(&B):');
  ////'&Border Color:');                                                                                                                                                                                           
  cxSetResourceString(@sdxAutoNodesExpand,'自动展开节点(&U)');
  ////'A&uto Nodes Expand');                                                                                                                                                                                
  cxSetResourceString(@sdxExpandLevel,'展开层次(&L):');
  ////'Expand &Level:');                                                                                                                                                                                           
  cxSetResourceString(@sdxFixedRowOnEveryPage,'固定每页行数(&E)');
  ////'Fixed Rows');

  cxSetResourceString(@sdxDrawMode,'绘制模式(&M):');
  ////'Draw &Mode:');                                                                                                                                                                                                 
  cxSetResourceString(@sdxDrawModeStrict,'精确');
  ////'Strict');                                                                                                                                                                                                         
  cxSetResourceString(@sdxDrawModeOddEven,'奇/偶行模式');
  ////'Odd/Even Rows Mode');                                                                                                                                                                                     
  cxSetResourceString(@sdxDrawModeChess,'国际象棋模式');
  ////'Chess Mode');                                                                                                                                                                                              
  cxSetResourceString(@sdxDrawModeBorrow,'从源借用');
  ////'Borrow From Source');                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdx3DEffects,'三维效果');
  ////'3D Effects');                                                                                                                                                                                                      
  cxSetResourceString(@sdxUse3DEffects,'使用三维效果(&3)');
  ////'Use &3D Effects');                                                                                                                                                                                      
  cxSetResourceString(@sdxSoft3D,'柔和三维(&3)');
  ////'Sof&t3D');                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxBehaviors,'性能');
  ////'Behaviors');                                                                                                                                                                                                           
  cxSetResourceString(@sdxMiscellaneous,'杂项');
  ////'Miscellaneous');                                                                                                                                                                                                   
  cxSetResourceString(@sdxOnEveryPage,'在每页');
  ////'On Every Page');                                                                                                                                                                                                   
  cxSetResourceString(@sdxNodeExpanding,'展开节点');
  ////'Node Expanding');                                                                                                                                                                                              
  cxSetResourceString(@sdxSelection,'选择');
  ////'Selection');                                                                                                                                                                                                           
  cxSetResourceString(@sdxNodeAutoHeight,'节点自动调整高度(&N)');
  ////'&Node Auto Height');                                                                                                                                                                              
  cxSetResourceString(@sdxTransparentGraphics,'图形透明(&T)');
  ////'&Transparent Graphics');                                                                                                                                                                             
  cxSetResourceString(@sdxAutoWidth,'自动调整宽度(&W)');
  ////'Auto &Width');                                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxDisplayGraphicsAsText,'用文本形式显示图形(&T)');
  ////'Display Graphic As &Text');                                                                                                                                                              
  cxSetResourceString(@sdxTransparentColumnGraphics,'图形透明(&G)');
  ////'Transparent &Graphics');                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxBandsOnEveryPage,'每页显示带区');
  ////'Bands');                                                                                                                                                                                                
  cxSetResourceString(@sdxHeadersOnEveryPage,'每页显示页眉');
  ////'Headers');                                                                                                                                                                                            
  cxSetResourceString(@sdxFootersOnEveryPage,'每页显示页脚');
  ////'Footers');                                                                                                                                                                                            
  cxSetResourceString(@sdxGraphics,'图形');
  ////'&Graphics');

  { Common messages }
  
  cxSetResourceString(@sdxOutOfResources,'资源不足');
  ////'Out of Resources');                                                                                                                                                                                           
  cxSetResourceString(@sdxFileAlreadyExists,'文件 "%s" 已经存在。');
  ////'File "%s" Already Exists.');                                                                                                                                                                   
  cxSetResourceString(@sdxConfirmOverWrite,'文件 "%s" 已经存在。 覆盖吗 ?');
  ////'File "%s" already exists. Overwrite ?');                                                                                                                                               
  cxSetResourceString(@sdxInvalidFileName,'无效的文件名 "%s"');
  ////'Invalid File Name "%s"');                                                                                                                                                                           
  cxSetResourceString(@sdxRequiredFileName,'输入文件名称。');
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
  cxSetResourceString(@sdxInvalidMargins,'一个或多个页边距是无效值');
  ////'One or more margins has invalid values');                                                                                                                                                     
  cxSetResourceString(@sdxOutsideMargins,'一个或多个页边距超出页面的可打印区域');
  ////'One or more margins are set outside the printable area of the page');                                                                                                             
  cxSetResourceString(@sdxThereAreNowItemsForShow,'没有项目');
  ////'There are no items in this view');

  { Color palette }
  
  cxSetResourceString(@sdxPageBackground,' 页面背景');
  ////' Page Background');                                                                                                                                                                                          
  cxSetResourceString(@sdxPenColor,'铅笔颜色');
  ////'Pen Color');                                                                                                                                                                                                        
  cxSetResourceString(@sdxFontColor,'字体颜色');
  ////'Font Color');                                                                                                                                                                                                      
  cxSetResourceString(@sdxBrushColor,'刷子颜色');
  ////'Brush Color');                                                                                                                                                                                                    
  cxSetResourceString(@sdxHighLight,'加亮');
  ////'HighLight');

  { Color names }
  
  cxSetResourceString(@sdxColorBlack,'黑色');
  ////'Black');                                                                                                                                                                                                              
  cxSetResourceString(@sdxColorDarkRed,'深红');
  ////'Dark Red');                                                                                                                                                                                                         
  cxSetResourceString(@sdxColorRed,'红色');
  ////'Red');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxColorPink,'粉红');
  ////'Pink');                                                                                                                                                                                                                
  cxSetResourceString(@sdxColorRose,'玫瑰红');
  ////'Rose');                                                                                                                                                                                                              
  cxSetResourceString(@sdxColorBrown,'褐色');
  ////'Brown');                                                                                                                                                                                                              
  cxSetResourceString(@sdxColorOrange,'桔黄');
  ////'Orange');                                                                                                                                                                                                            
  cxSetResourceString(@sdxColorLightOrange,'浅桔黄');
  ////'Light Orange');                                                                                                                                                                                               
  cxSetResourceString(@sdxColorGold,'金色');
  ////'Gold');                                                                                                                                                                                                                
  cxSetResourceString(@sdxColorTan,'棕黄');
  ////'Tan');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxColorOliveGreen,'橄榄绿');
  ////'Olive Green');                                                                                                                                                                                                 
  cxSetResourceString(@sdxColorDrakYellow,'深黄');
  ////'Dark Yellow');                                                                                                                                                                                                   
  cxSetResourceString(@sdxColorLime,'酸橙色');
  ////'Lime');                                                                                                                                                                                                              
  cxSetResourceString(@sdxColorYellow,'黄色');
  ////'Yellow');                                                                                                                                                                                                            
  cxSetResourceString(@sdxColorLightYellow,'浅黄');
  ////'Light Yellow');                                                                                                                                                                                                 
  cxSetResourceString(@sdxColorDarkGreen,'深绿');
  ////'Dark Green');                                                                                                                                                                                                     
  cxSetResourceString(@sdxColorGreen,'绿色');
  ////'Green');                                                                                                                                                                                                              
  cxSetResourceString(@sdxColorSeaGreen,'海绿');
  ////'Sea Green');                                                                                                                                                                                                       
  cxSetResourceString(@sdxColorBrighthGreen,'鲜绿');
  ////'Bright Green');                                                                                                                                                                                                
  cxSetResourceString(@sdxColorLightGreen,'浅绿');
  ////'Light Green');                                                                                                                                                                                                   
  cxSetResourceString(@sdxColorDarkTeal,'深灰蓝');
  ////'Dark Teal');                                                                                                                                                                                                     
  cxSetResourceString(@sdxColorTeal,'青色');
  ////'Teal');                                                                                                                                                                                                                
  cxSetResourceString(@sdxColorAqua,'宝石蓝');
  ////'Aqua');                                                                                                                                                                                                              
  cxSetResourceString(@sdxColorTurquoise,'青绿');
  ////'Turquoise');                                                                                                                                                                                                      
  cxSetResourceString(@sdxColorLightTurquoise,'浅青绿');
  ////'Light Turquoise');                                                                                                                                                                                         
  cxSetResourceString(@sdxColorDarkBlue,'深蓝');
  ////'Dark Blue');                                                                                                                                                                                                       
  cxSetResourceString(@sdxColorBlue,'蓝色');
  ////'Blue');                                                                                                                                                                                                                
  cxSetResourceString(@sdxColorLightBlue,'浅蓝');
  ////'Light Blue');                                                                                                                                                                                                     
  cxSetResourceString(@sdxColorSkyBlue,'天蓝');
  ////'Sky Blue');                                                                                                                                                                                                         
  cxSetResourceString(@sdxColorPaleBlue,'淡蓝');
  ////'Pale Blue');                                                                                                                                                                                                       
  cxSetResourceString(@sdxColorIndigo,'靛蓝');
  ////'Indigo');                                                                                                                                                                                                            
  cxSetResourceString(@sdxColorBlueGray,'蓝-灰');
  ////'Blue Gray');                                                                                                                                                                                                      
  cxSetResourceString(@sdxColorViolet,'紫色');
  ////'Violet');                                                                                                                                                                                                            
  cxSetResourceString(@sdxColorPlum,'梅红');
  ////'Plum');                                                                                                                                                                                                                
  cxSetResourceString(@sdxColorLavender,'淡紫');
  ////'Lavender');                                                                                                                                                                                                        
  cxSetResourceString(@sdxColorGray80,'灰色-80%');
  ////'Gray-80%');                                                                                                                                                                                                      
  cxSetResourceString(@sdxColorGray50,'灰色-50%');
  ////'Gray-50%');                                                                                                                                                                                                      
  cxSetResourceString(@sdxColorGray40,'灰色-40%');
  ////'Gray-40%');                                                                                                                                                                                                      
  cxSetResourceString(@sdxColorGray25,'灰色-25%');
  ////'Gray-25%');                                                                                                                                                                                                      
  cxSetResourceString(@sdxColorWhite,'白色');
  ////'White');
 
  { FEF Dialog }
  
  cxSetResourceString(@sdxTexture,'纹理(&T)');
  ////'&Texture');                                                                                                                                                                                                          
  cxSetResourceString(@sdxPattern,'图案(&P)');
  ////'&Pattern');                                                                                                                                                                                                          
  cxSetResourceString(@sdxPicture,'图片(&I)');
  ////'P&icture');                                                                                                                                                                                                          
  cxSetResourceString(@sdxForeground,'前景(&F)');
  ////'&Foreground');                                                                                                                                                                                                    
  cxSetResourceString(@sdxBackground,'背景(&B)');
  ////'&Background');                                                                                                                                                                                                    
  cxSetResourceString(@sdxSample,'示范:');
  ////'Sample:');                                                                                                                                                                                                               
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxFEFCaption,'填充效果');
  ////'Fill Effects');                                                                                                                                                                                                   
  cxSetResourceString(@sdxPaintMode,'画图模式');
  ////'Paint &Mode');                                                                                                                                                                                                     
  cxSetResourceString(@sdxPaintModeCenter,'居中');
  ////'Center');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPaintModeStretch,'拉伸');
  ////'Stretch');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPaintModeTile,'平铺');
  ////'Tile');                                                                                                                                                                                                            
  cxSetResourceString(@sdxPaintModeProportional,'锁定比例');
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
  cxSetResourceString(@sdxPatternLightDownwardDiagonal,'浅色下对角线');
  ////'Light downward diagonal');                                                                                                                                                                  
  cxSetResourceString(@sdxPatternLightUpwardDiagonal,'浅色上对角线');
  ////'Light upward diagonal');                                                                                                                                                                      
  cxSetResourceString(@sdxPatternDarkDownwardDiagonal,'深色下对角线');
  ////'Dark downward diagonal');                                                                                                                                                                    
  cxSetResourceString(@sdxPatternDarkUpwardDiagonal,'深色上对角线');
  ////'Dark upward diagonal');                                                                                                                                                                        
  cxSetResourceString(@sdxPatternWideDownwardDiagonal,'宽下对角线');
  ////'Wide downward diagonal');                                                                                                                                                                      
  cxSetResourceString(@sdxPatternWideUpwardDiagonal,'宽上对角线');
  ////'Wide upward diagonal');                                                                                                                                                                          
  cxSetResourceString(@sdxPatternLightVertical,'浅色垂线');
  ////'Light vertical');                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternLightHorizontal,'浅色横线');
  ////'Light horizontal');                                                                                                                                                                                   
  cxSetResourceString(@sdxPatternNarrowVertical,'窄竖线');
  ////'Narrow vertical');                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternNarrowHorizontal,'窄横线');
  ////'Narrow horizontal');                                                                                                                                                                                   
  cxSetResourceString(@sdxPatternDarkVertical,'深色竖线');
  ////'Dark vertical');                                                                                                                                                                                         
  cxSetResourceString(@sdxPatternDarkHorizontal,'深色横线');
  ////'Dark horizontal');                                                                                                                                                                                     
  cxSetResourceString(@sdxPatternDashedDownward,'下对角虚线');
  ////'Dashed downward');                                                                                                                                                                                   
  cxSetResourceString(@sdxPatternDashedUpward,'上对角虚线');
  ////'Dashed upward');                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternDashedVertical,'横虚线');
  ////'Dashed vertical');                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternDashedHorizontal,'竖虚线');
  ////'Dashed horizontal');                                                                                                                                                                                   
  cxSetResourceString(@sdxPatternSmallConfetti,'小纸屑');
  ////'Small confetti');                                                                                                                                                                                         
  cxSetResourceString(@sdxPatternLargeConfetti,'大纸屑');
  ////'Large confetti');                                                                                                                                                                                         
  cxSetResourceString(@sdxPatternZigZag,'之字形');
  ////'Zig zag');                                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternWave,'波浪线');
  ////'Wave');                                                                                                                                                                                                            
  cxSetResourceString(@sdxPatternDiagonalBrick,'对角砖形');
  ////'Diagonal brick');                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternHorizantalBrick,'横向砖形');
  ////'Horizontal brick');                                                                                                                                                                                   
  cxSetResourceString(@sdxPatternWeave,'编织物');
  ////'Weave');                                                                                                                                                                                                          
  cxSetResourceString(@sdxPatternPlaid,'苏格兰方格呢');
  ////'Plaid');                                                                                                                                                                                                    
  cxSetResourceString(@sdxPatternDivot,'草皮');
  ////'Divot');                                                                                                                                                                                                            
  cxSetResourceString(@sdxPatternDottedGrid,'虚线网格');
  ////'Dottedgrid');                                                                                                                                                                                              
  cxSetResourceString(@sdxPatternDottedDiamond,'点式菱形');
  ////'Dotted diamond');                                                                                                                                                                                       
  cxSetResourceString(@sdxPatternShingle,'瓦形');
  ////'Shingle');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPatternTrellis,'棚架');
  ////'Trellis');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPatternSphere,'球体');
  ////'Sphere');                                                                                                                                                                                                          
  cxSetResourceString(@sdxPatternSmallGrid,'小网格');
  ////'Small grid');                                                                                                                                                                                                 
  cxSetResourceString(@sdxPatternLargeGrid,'大网格');
  ////'Large grid');                                                                                                                                                                                                 
  cxSetResourceString(@sdxPatternSmallCheckedBoard,'小棋盘');
  ////'Small checked board');                                                                                                                                                                                
  cxSetResourceString(@sdxPatternLargeCheckedBoard,'大棋盘');
  ////'Large checked board');                                                                                                                                                                                
  cxSetResourceString(@sdxPatternOutlinedDiamond,'轮廓式菱形');
  ////'Outlined diamond');                                                                                                                                                                                 
  cxSetResourceString(@sdxPatternSolidDiamond,'实心菱形');
  ////'Solid diamond');                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  { Texture names }                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxTextureNewSprint,'新闻纸');
  ////'Newsprint');                                                                                                                                                                                                  
  cxSetResourceString(@sdxTextureGreenMarble,'绿色大理石');
  ////'Green marble');                                                                                                                                                                                         
  cxSetResourceString(@sdxTextureBlueTissuePaper,'蓝色砂纸');
  ////'Blue tissue paper');                                                                                                                                                                                  
  cxSetResourceString(@sdxTexturePapyrus,'纸莎草纸');
  ////'Papyrus');                                                                                                                                                                                                    
  cxSetResourceString(@sdxTextureWaterDroplets,'水滴');
  ////'Water droplets');                                                                                                                                                                                           
  cxSetResourceString(@sdxTextureCork,'软木塞');
  ////'Cork');                                                                                                                                                                                                            
  cxSetResourceString(@sdxTextureRecycledPaper,'再生纸');
  ////'Recycled paper');                                                                                                                                                                                         
  cxSetResourceString(@sdxTextureWhiteMarble,'白色大理石');
  ////'White marble');                                                                                                                                                                                         
  cxSetResourceString(@sdxTexturePinkMarble,'粉色砂纸');
  ////'Pink marble');                                                                                                                                                                                             
  cxSetResourceString(@sdxTextureCanvas,'画布');
  ////'Canvas');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTexturePaperBag,'纸袋');
  ////'Paper bag');                                                                                                                                                                                                     
  cxSetResourceString(@sdxTextureWalnut,'胡桃');
  ////'Walnut');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTextureParchment,'羊皮纸');
  ////'Parchment');                                                                                                                                                                                                  
  cxSetResourceString(@sdxTextureBrownMarble,'棕色大理石');
  ////'Brown marble');                                                                                                                                                                                         
  cxSetResourceString(@sdxTexturePurpleMesh,'紫色网格');
  ////'Purple mesh');                                                                                                                                                                                             
  cxSetResourceString(@sdxTextureDenim,'斜纹布');
  ////'Denim');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTextureFishFossil,'鱼类化石');
  ////'Fish fossil');                                                                                                                                                                                             
  cxSetResourceString(@sdxTextureOak,'栎木');
  ////'Oak');                                                                                                                                                                                                                
  cxSetResourceString(@sdxTextureStationary,'信纸');
  ////'Stationary');                                                                                                                                                                                                  
  cxSetResourceString(@sdxTextureGranite,'花岗岩');
  ////'Granite');                                                                                                                                                                                                      
  cxSetResourceString(@sdxTextureBouquet,'花束');
  ////'Bouquet');                                                                                                                                                                                                        
  cxSetResourceString(@sdxTextureWonenMat,'编织物');
  ////'Woven mat');                                                                                                                                                                                                   
  cxSetResourceString(@sdxTextureSand,'沙滩');
  ////'Sand');                                                                                                                                                                                                              
  cxSetResourceString(@sdxTextureMediumWood,'深色木质');
  ////'Medium wood');                                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxFSPCaption,'图像预览');
  ////'Picture Preview');                                                                                                                                                                                                
  cxSetResourceString(@sdxWidth,'宽度');
  ////'Width');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxHeight,'高度');
  ////'Height');                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                          
  { Brush Dialog }                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxBrushDlgCaption,'画笔属性');
  ////'Brush properties');                                                                                                                                                                                          
  cxSetResourceString(@sdxStyle,'样式:');
  ////'&Style:');                                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  { Enter New File Name dialog }                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxENFNCaption,'选择新文件名称');
  ////'Choose New File Name');                                                                                                                                                                                    
  cxSetResourceString(@sdxEnterNewFileName,'输入新文件名称');
  ////'Enter New File Name');                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  { Define styles dialog }                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxDefinePrintStylesCaption,'定义打印样式');
  ////'Define Print Styles');                                                                                                                                                                          
  cxSetResourceString(@sdxDefinePrintStylesTitle,'打印样式(&S)');
  ////'Print &Styles');                                                                                                                                                                                  
  cxSetResourceString(@sdxDefinePrintStylesWarningDelete,'确认要删除 "%s" 吗?');
  ////'Do you want to delete "%s" ?');                                                                                                                                                    
  cxSetResourceString(@sdxDefinePrintStylesWarningClear,'要删除所有非内置样式吗?');
  ////'Do you want to delete all not built-in styles ?');                                                                                                                              
  cxSetResourceString(@sdxClear,'清除(&L)...');
  ////'C&lear...');                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  { Print device }                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCustomSize,'自定义大小');
  ////'Custom Size');                                                                                                                                                                                                  
  cxSetResourceString(@sdxDefaultTray,'默认纸盒');
  ////'Default Tray');                                                                                                                                                                                                  
  cxSetResourceString(@sdxInvalidPrintDevice,'所选打印机无效');
  ////'Printer selected is not valid');                                                                                                                                                                    
  cxSetResourceString(@sdxNotPrinting,'当前打印机不打印');
  ////'Printer is not currently printing');                                                                                                                                                                     
  cxSetResourceString(@sdxPrinting,'正在打印');
  ////'Printing in progress');                                                                                                                                                                                             
  cxSetResourceString(@sdxDeviceOnPort,'%s 在 %s');
  ////'%s on %s');                                                                                                                                                                                                     
  cxSetResourceString(@sdxPrinterIndexError,'打印机索引超出范围');
  ////'Printer index out of range');                                                                                                                                                                    
  cxSetResourceString(@sdxNoDefaultPrintDevice,'没有选择默认打印机');
  ////'There is no default printer selected');                                                                                                                                                       
                                                                                                                                                                                                                                                          
  { Edit AutoText Entries Dialog }                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxAutoTextDialogCaption,'编辑自动图文集');
  ////'Edit AutoText Entries');                                                                                                                                                                         
  cxSetResourceString(@sdxEnterAutoTextEntriesHere,'输入自动图文集：');
  ////' Enter A&utoText Entries Here: ');                                                                                                                                                          
                                                                                                                                                                                                                                                          
  { Print dialog }                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPrintDialogCaption,'打印');
  ////'Print');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintDialogPrinter,'打印机');
  ////' Printer ');                                                                                                                                                                                                
  cxSetResourceString(@sdxPrintDialogName,'名称(&N):');
  ////'&Name:');                                                                                                                                                                                                   
  cxSetResourceString(@sdxPrintDialogStatus,'状态:');
  ////'Status:');                                                                                                                                                                                                    
  cxSetResourceString(@sdxPrintDialogType,'类型:');
  ////'Type:');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPrintDialogWhere,'位置:');
  ////'Where:');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintDialogComment,'备注:');
  ////'Comment:');                                                                                                                                                                                                  
  cxSetResourceString(@sdxPrintDialogPrintToFile,'打印到文件(&F)');
  ////'Print to &File');                                                                                                                                                                               
  cxSetResourceString(@sdxPrintDialogPageRange,' 页面范围 ');
  ////' Page range ');                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDialogAll,'全部(&A)');
  ////'&All');                                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDialogCurrentPage,'当前页(&E)');
  ////'Curr&ent Page');                                                                                                                                                                                    
  cxSetResourceString(@sdxPrintDialogSelection,'所选内容(&S)');
  ////'&Selection');                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDialogPages,'页码范围:');
  ////'&Pages:');                                                                                                                                                                                                 
  cxSetResourceString(@sdxPrintDialogRangeLegend,'请键入页码和/或用逗号分隔的页码范围'+#10#13+
  ////'Enter page number and/or page ranges' + #10#13 +                                                                                                                   
    'separated by commas. For example: 1,3,5-12.');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPrintDialogCopies,' 副本');
  ////' Copies ');                                                                                                                                                                                                   
  cxSetResourceString(@sdxPrintDialogNumberOfPages,'页数(&U):');
  ////'N&umber of Pages:');                                                                                                                                                                               
  cxSetResourceString(@sdxPrintDialogNumberOfCopies,'份数(&C):');
  ////'Number of &Copies:');                                                                                                                                                                             
  cxSetResourceString(@sdxPrintDialogCollateCopies,'逐份打印(&T)');
  ////'Colla&te Copies');                                                                                                                                                                              
  cxSetResourceString(@sdxPrintDialogAllPages,'全部');
  ////'All');                                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDialogEvenPages,'偶数页');
  ////'Even');                                                                                                                                                                                                   
  cxSetResourceString(@sdxPrintDialogOddPages,'奇数页');
  ////'Odd');                                                                                                                                                                                                     
  cxSetResourceString(@sdxPrintDialogPrintStyles,' 打印样式(&Y)');
  ////' Print St&yles ');                                                                                                                                                                               
                                                                                                                                                                                                                                                          
  { PrintToFile Dialog }                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPrintDialogOpenDlgTitle,'选择文件名称');
  ////'Choose File Name');                                                                                                                                                                              
  cxSetResourceString(@sdxPrintDialogOpenDlgAllFiles,'全部文件');
  ////'All Files');                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintDialogOpenDlgPrinterFiles,'打印机文件');
  ////'Printer Files');                                                                                                                                                                            
  cxSetResourceString(@sdxPrintDialogPageNumbersOutOfRange,'页码超出范围 (%d - %d)');
  ////'Page numbers out of range (%d - %d)');                                                                                                                                        
  cxSetResourceString(@sdxPrintDialogInvalidPageRanges,'无效的页码范围');
  ////'Invalid page ranges');                                                                                                                                                                    
  cxSetResourceString(@sdxPrintDialogRequiredPageNumbers,'输入页码');
  ////'Enter page numbers');                                                                                                                                                                         
  cxSetResourceString(@sdxPrintDialogNoPrinters,'没有安装打印机。 要安装打印机，'+
  ////'No printers are installed. To install a printer, ' +                                                                                                                           
    'point to Settings on the Windows Start menu, click Printers, and then double-click Add Printer. ' +                                                                                                                                                  
    'Follow the instructions in the wizard.');                                                                                                                                                                                                             
  cxSetResourceString(@sdxPrintDialogInPrintingState,'打印机正在打印。'+#10#13+
  ////'Printer is currently printing.' + #10#13 +                                                                                                                                        
    'Please wait.');                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  { Printer State }                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPrintDialogPSPaused,'暂停');
  ////'Paused');                                                                                                                                                                                                    
  cxSetResourceString(@sdxPrintDialogPSPendingDeletion,'正在删除');
  ////'Pending Deletion');                                                                                                                                                                             
  cxSetResourceString(@sdxPrintDialogPSBusy,'繁忙');
  ////'Busy');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPrintDialogPSDoorOpen,'通道打开');
  ////'Door Open');                                                                                                                                                                                           
  cxSetResourceString(@sdxPrintDialogPSError,'错误');
  ////'Error');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintDialogPSInitializing,'初始化');
  ////'Initializing');                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintDialogPSIOActive,'输入输出有效');
  ////'IO Active');                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDialogPSManualFeed,'手工送纸');
  ////'Manual Feed');                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDialogPSNoToner,'没有墨粉');
  ////'No Toner');                                                                                                                                                                                             
  cxSetResourceString(@sdxPrintDialogPSNotAvailable,'不可用');
  ////'Not Available');                                                                                                                                                                                     
  cxSetResourceString(@sdxPrintDialogPSOFFLine,'脱机');
  ////'Offline');                                                                                                                                                                                                  
  cxSetResourceString(@sdxPrintDialogPSOutOfMemory,'内存溢出');
  ////'Out of Memory');                                                                                                                                                                                    
  cxSetResourceString(@sdxPrintDialogPSOutBinFull,'输出储存器已满');
  ////'Output Bin Full');                                                                                                                                                                             
  cxSetResourceString(@sdxPrintDialogPSPagePunt,'页平底');
  ////'Page Punt');                                                                                                                                                                                             
  cxSetResourceString(@sdxPrintDialogPSPaperJam,'卡纸');
  ////'Paper Jam');                                                                                                                                                                                               
  cxSetResourceString(@sdxPrintDialogPSPaperOut,'纸张跳出');
  ////'Paper Out');                                                                                                                                                                                           
  cxSetResourceString(@sdxPrintDialogPSPaperProblem,'纸张问题');
  ////'Paper Problem');                                                                                                                                                                                   
  cxSetResourceString(@sdxPrintDialogPSPrinting,'正在打印');
  ////'Printing');                                                                                                                                                                                            
  cxSetResourceString(@sdxPrintDialogPSProcessing,'正在处理');
  ////'Processing');                                                                                                                                                                                        
  cxSetResourceString(@sdxPrintDialogPSTonerLow,'墨粉较少');
  ////'Toner Low');                                                                                                                                                                                           
  cxSetResourceString(@sdxPrintDialogPSUserIntervention,'需用户干涉');
  ////'User Intervention');                                                                                                                                                                         
  cxSetResourceString(@sdxPrintDialogPSWaiting,'正在等待');
  ////'Waiting');                                                                                                                                                                                              
  cxSetResourceString(@sdxPrintDialogPSWarningUp,'正在预热');
  ////'Warming Up');                                                                                                                                                                                         
  cxSetResourceString(@sdxPrintDialogPSReady,'就绪');
  ////'Ready');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintDialogPSPrintingAndWaiting,'正在打印：%d document(s)  请等待');
  ////'Printing: %d document(s) waiting');                                                                                                                                  
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxLeftMargin,'左边距');
  ////'Left Margin');                                                                                                                                                                                                      
  cxSetResourceString(@sdxTopMargin,'上边距');
  ////'Top Margin');                                                                                                                                                                                                        
  cxSetResourceString(@sdxRightMargin,'右边距');
  ////'Right Margin');                                                                                                                                                                                                    
  cxSetResourceString(@sdxBottomMargin,'下边距');
  ////'Bottom Margin');                                                                                                                                                                                                  
  cxSetResourceString(@sdxGutterMargin,'装订线');
  ////'Gutter');                                                                                                                                                                                                         
  cxSetResourceString(@sdxHeaderMargin,'页眉');
  ////'Header');                                                                                                                                                                                                           
  cxSetResourceString(@sdxFooterMargin,'页脚');
  ////'Footer');                                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxUnitsInches,'"');
  ////'"');                                                                                                                                                                                                                    
  cxSetResourceString(@sdxUnitsCentimeters,'厘米');
  ////'cm');                                                                                                                                                                                                           
  cxSetResourceString(@sdxUnitsMillimeters,'毫米');
  ////'mm');                                                                                                                                                                                                           
  cxSetResourceString(@sdxUnitsPoints,'磅');
  ////'pt');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxUnitsPicas,'像素');
  ////'pi');                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxUnitsDefaultName,'默认');
  ////'Default');                                                                                                                                                                                                      
  cxSetResourceString(@sdxUnitsInchesName,'英寸');
  ////'Inches');                                                                                                                                                                                                        
  cxSetResourceString(@sdxUnitsCentimetersName,'厘米');
  ////'Centimeters');                                                                                                                                                                                              
  cxSetResourceString(@sdxUnitsMillimetersName,'毫米');
  ////'Millimeters');                                                                                                                                                                                              
  cxSetResourceString(@sdxUnitsPointsName,'磅');
  ////'Points');                                                                                                                                                                                                          
  cxSetResourceString(@sdxUnitsPicasName,'派卡');
  ////'Picas');                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPrintPreview,'打印预览');
  ////'Print Preview');                                                                                                                                                                                                
  cxSetResourceString(@sdxReportDesignerCaption,'报表设计');
  ////'Format Report');                                                                                                                                                                                       
  cxSetResourceString(@sdxCompositionDesignerCaption,'布局设计');
  ////'Composition Editor');                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxComponentNotSupportedByLink,'组件 "%s" 不被打印组件支持');
  ////'Component "%s" not supported by TdxComponentPrinter');                                                                                                                         
  cxSetResourceString(@sdxComponentNotSupported,'组件 "%s" 不被打印组件支持');
  ////'Component "%s" not supported by TdxComponentPrinter');                                                                                                                               
  cxSetResourceString(@sdxPrintDeviceNotReady,'打印机尚未安装或者没有就绪');
  ////'Printer has not been installed or is not ready');                                                                                                                                      
  cxSetResourceString(@sdxUnableToGenerateReport,'不能产生报表');
  ////'Unable to generate report');                                                                                                                                                                      
  cxSetResourceString(@sdxPreviewNotRegistered,'没有已注册的预览表单');
  ////'There is no registered preview form');                                                                                                                                                      
  cxSetResourceString(@sdxComponentNotAssigned,'%s' + #13#10 + '没有指定组件属性');
  ////'%s' + #13#10 + 'Not assigned "Component" property');                                                                                                                            
  cxSetResourceString(@sdxPrintDeviceIsBusy,'打印机正忙');
  ////'Printer is busy');                                                                                                                                                                                       
  cxSetResourceString(@sdxPrintDeviceError,'打印机出错!');
  ////'Printer has encountered error !');                                                                                                                                                                       
  cxSetResourceString(@sdxMissingComponent,'缺少组件属性');
  ////'Missing "Component" property');                                                                                                                                                                         
  cxSetResourceString(@sdxDataProviderDontPresent,'在布局中没有指定连接的组件');
  ////'There are no Links with Assigned Component in Composition');                                                                                                                       
  cxSetResourceString(@sdxBuildingReport,'构建报表：已完成 %d%%');
  ////'Building report: Completed %d%%');                            // obsolete                                                                                                                        
  cxSetResourceString(@sdxPrintingReport,'正在打印报表：已完成 %d 页。 按ESC键中断...');
  ////'Printing report: Completed %d page(s). Press Esc to cancel'); // obsolete                                                                                                  
  cxSetResourceString(@sdxDefinePrintStylesMenuItem,'定义打印样式(&S)...');
  ////'Define Print &Styles...');                                                                                                                                                              
  cxSetResourceString(@sdxAbortPrinting,'要中断打印吗?');
  ////'Abort printing ?');                                                                                                                                                                                       
  cxSetResourceString(@sdxStandardStyle,'标准样式');
  ////'Standard Style');                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxFontStyleBold,'黑体');
  ////'Bold');                                                                                                                                                                                                            
  cxSetResourceString(@sdxFontStyleItalic,'斜体');
  ////'Italic');                                                                                                                                                                                                        
  cxSetResourceString(@sdxFontStyleUnderline,'下划线');
  ////'Underline');                                                                                                                                                                                                
  cxSetResourceString(@sdxFontStyleStrikeOut,'删除线');
  ////'StrikeOut');                                                                                                                                                                                                
  cxSetResourceString(@sdxPt,'磅');
  ////'pt.');                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxNoPages,'[没有页面]');
  ////'There are no pages to display');                                                                                                                                                                                   
  cxSetResourceString(@sdxPageWidth,'页宽');
  ////'Page Width');                                                                                                                                                                                                          
  cxSetResourceString(@sdxWholePage,'整页');
  ////'Whole Page');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTwoPages,'两页');
  ////'Two Pages');                                                                                                                                                                                                            
  cxSetResourceString(@sdxFourPages,'四页');
  ////'Four Pages');                                                                                                                                                                                                          
  cxSetResourceString(@sdxWidenToSourceWidth,'原始宽度');
  ////'Widen to Source Width');                                                                                                                                                                                  
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuBar,'菜单栏');
  ////'MenuBar');                                                                                                                                                                                                             
  cxSetResourceString(@sdxStandardBar,'标准');
  ////'Standard');                                                                                                                                                                                                          
  cxSetResourceString(@sdxHeaderFooterBar,'页眉和页脚');
  ////'Header and Footer');                                                                                                                                                                                       
  cxSetResourceString(@sdxShortcutMenusBar,'快捷菜单');
  ////'Shortcut Menus');                                                                                                                                                                                           
  cxSetResourceString(@sdxAutoTextBar,'自动图文集');
  ////'AutoText');                                                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuFile,'文件(&F)');
  ////'&File');                                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuFileDesign,'设计(&D)...');
  ////'&Design...');                                                                                                                                                                                              
  cxSetResourceString(@sdxMenuFilePrint,'打印(&P)...');
  ////'&Print...');                                                                                                                                                                                                
  cxSetResourceString(@sdxMenuFilePageSetup,'页面设置(&U)...');
  ////'Page Set&up...');                                                                                                                                                                                   
  cxSetResourceString(@sdxMenuPrintStyles,'打印样式');
  ////'Print Styles');                                                                                                                                                                                              
  cxSetResourceString(@sdxMenuFileExit,'关闭(&C)');
  ////'&Close');                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuEdit,'编辑(&E)');
  ////'&Edit');                                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuEditCut,'剪切(&T)');
  ////'Cu&t');                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuEditCopy,'复制(&C)');
  ////'&Copy');                                                                                                                                                                                                        
  cxSetResourceString(@sdxMenuEditPaste,'粘贴(&P)');
  ////'&Paste');                                                                                                                                                                                                      
  cxSetResourceString(@sdxMenuEditDelete,'删除(&D)');
  ////'&Delete');                                                                                                                                                                                                    
  cxSetResourceString(@sdxMenuEditFind,'查找(&F)...');
  ////'&Find...');                                                                                                                                                                                                  
  cxSetResourceString(@sdxMenuEditFindNext,'查找下一个(&X)');
  ////'Find Ne&xt');                                                                                                                                                                                         
  cxSetResourceString(@sdxMenuEditReplace,'替换(&R)...');
  ////'&Replace...');                                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuLoad,'加载(&L)...');
  ////'&Load...');                                                                                                                                                                                                      
  cxSetResourceString(@sdxMenuPreview,'预览(&V)...');
  ////'Pre&view...');                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuInsert,'插入(&I)');
  ////'&Insert');                                                                                                                                                                                                        
  cxSetResourceString(@sdxMenuInsertAutoText,'自动图文集(&A)');
  ////'&AutoText');                                                                                                                                                                                        
  cxSetResourceString(@sdxMenuInsertEditAutoTextEntries,'自动图文集(&X)...');
  ////'AutoTe&xt...');                                                                                                                                                                       
  cxSetResourceString(@sdxMenuInsertAutoTextEntries,'自动图文集列表');
  ////'List of AutoText Entries');                                                                                                                                                                  
  cxSetResourceString(@sdxMenuInsertAutoTextEntriesSubItem,'插入自动图文集(&S)');
  ////'In&sert AutoText');                                                                                                                                                               
  cxSetResourceString(@sdxMenuInsertPageNumber,'页码(&P)');
  ////'&Page Number');                                                                                                                                                                                         
  cxSetResourceString(@sdxMenuInsertTotalPages,'页数(&N)');
  ////'&Number of Pages');                                                                                                                                                                                     
  cxSetResourceString(@sdxMenuInsertPageOfPages,'页面页码(&G)');
  ////'Pa&ge Number of Pages');                                                                                                                                                                           
  cxSetResourceString(@sdxMenuInsertDateTime,'日期和时间');
  ////'Date and Time');                                                                                                                                                                                        
  cxSetResourceString(@sdxMenuInsertDate,'日期(&D)');
  ////'&Date');                                                                                                                                                                                                      
  cxSetResourceString(@sdxMenuInsertTime,'时间(&T)');
  ////'&Time');                                                                                                                                                                                                      
  cxSetResourceString(@sdxMenuInsertUserName,'用户名称(&U)');
  ////'&User Name');                                                                                                                                                                                         
  cxSetResourceString(@sdxMenuInsertMachineName,'机器名称(&M)');
  ////'&Machine Name');                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuView,'视图(&V)');
  ////'&View');                                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuViewMargins,'页边距(&M)');
  ////'&Margins');                                                                                                                                                                                                
  cxSetResourceString(@sdxMenuViewFlatToolBarButtons,'平面工具栏按钮');
  ////'&Flat ToolBar Buttons');                                                                                                                                                                    
  cxSetResourceString(@sdxMenuViewLargeToolBarButtons,'大工具栏按钮');
  ////'&Large ToolBar Buttons');                                                                                                                                                                    
  cxSetResourceString(@sdxMenuViewMarginsStatusBar,'页边距栏');
  ////'M&argins Bar');                                                                                                                                                                                     
  cxSetResourceString(@sdxMenuViewPagesStatusBar,'状态栏');
  ////'&Status Bar');                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuViewToolBars,'工具栏');
  ////'&Toolbars');                                                                                                                                                                                                  
  cxSetResourceString(@sdxMenuViewPagesHeaders,'页眉');
  ////'Page &Headers');                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuViewPagesFooters,'页脚');
  ////'Page Foote&rs');                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuViewSwitchToLeftPart,'切换到左部');
  ////'Switch to Left Part');                                                                                                                                                                            
  cxSetResourceString(@sdxMenuViewSwitchToRightPart,'切换到右部');
  ////'Switch to Right Part');                                                                                                                                                                          
  cxSetResourceString(@sdxMenuViewSwitchToCenterPart,'切换到中部');
  ////'Switch to Center Part');                                                                                                                                                                        
  cxSetResourceString(@sdxMenuViewHFSwitchHeaderFooter,'显示页眉/页脚(&S)');
  ////'&Show Header/Footer');                                                                                                                                                                 
  cxSetResourceString(@sdxMenuViewHFClose,'关闭(&C)');
  ////'&Close');                                                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuZoom,'缩放(&Z)');
  ////'&Zoom');                                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuZoomPercent100,'百分&100');
  ////'Percent &100');                                                                                                                                                                                           
  cxSetResourceString(@sdxMenuZoomPageWidth,'页宽(&W)');
  ////'Page &Width');                                                                                                                                                                                             
  cxSetResourceString(@sdxMenuZoomWholePage,'整页(&H)');
  ////'W&hole Page');                                                                                                                                                                                             
  cxSetResourceString(@sdxMenuZoomTwoPages,'两页(&T)');
  ////'&Two Pages');                                                                                                                                                                                               
  cxSetResourceString(@sdxMenuZoomFourPages,'四页(&F)');
  ////'&Four Pages');                                                                                                                                                                                             
  cxSetResourceString(@sdxMenuZoomMultiplyPages,'多页(&M)');
  ////'&Multiple Pages');                                                                                                                                                                                     
  cxSetResourceString(@sdxMenuZoomWidenToSourceWidth,'扩展到原始宽度');
  ////'Widen To S&ource Width');                                                                                                                                                                   
  cxSetResourceString(@sdxMenuZoomSetup,'设置(&S)...');
  ////'&Setup...');                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuPages,'页面(&P)');
  ////'&Pages');                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuGotoPage,'转到(&G)');
  ////'&Go');                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuGotoPageFirst,'首页(&F)');
  ////'&First Page');                                                                                                                                                                                             
  cxSetResourceString(@sdxMenuGotoPagePrev,'前一页(&P)');
  ////'&Previous Page');                                                                                                                                                                                         
  cxSetResourceString(@sdxMenuGotoPageNext,'下一页(&N)');
  ////'&Next Page');                                                                                                                                                                                             
  cxSetResourceString(@sdxMenuGotoPageLast,'尾页(&L)');
  ////'&Last Page');                                                                                                                                                                                               
  cxSetResourceString(@sdxMenuActivePage,'当前页(&A):');
  ////'&Active Page:');                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuFormat,'格式(&O)');
  ////'F&ormat');                                                                                                                                                                                                        
  cxSetResourceString(@sdxMenuFormatHeaderAndFooter,'页眉和页脚');
  ////'&Header and Footer');                                                                                                                                                                            
  cxSetResourceString(@sdxMenuFormatAutoTextEntries,'自动图文集(&A)...');
  ////'&Auto Text Entries...');                                                                                                                                                                  
  cxSetResourceString(@sdxMenuFormatDateTime,'日期和时间(&T)...');
  ////'Date And &Time...');                                                                                                                                                                             
  cxSetResourceString(@sdxMenuFormatPageNumbering,'页码(&N)...');
  ////'Page &Numbering...');                                                                                                                                                                             
  cxSetResourceString(@sdxMenuFormatPageBackground,'背景(&K)...');
  ////'Bac&kground...');                                                                                                                                                                                
  cxSetResourceString(@sdxMenuFormatShrinkToPage,'缩小适合页面(&F)');
  ////'&Fit to Page');                                                                                                                                                                               
  cxSetResourceString(@sdxMenuShowEmptyPages,'显示空白页(&E)');
  ////'Show &Empty Pages');                                                                                                                                                                                
  cxSetResourceString(@sdxMenuFormatHFBackground,'页眉/页脚背景...');
  ////'Header/Footer Background...');                                                                                                                                                                
  cxSetResourceString(@sdxMenuFormatHFClear,'清除文本');
  ////'Clear Text');                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuTools,'工具(&T)');
  ////'&Tools');                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuToolsCustomize,'自定义(&C)...');
  ////'&Customize...');                                                                                                                                                                                     
  cxSetResourceString(@sdxMenuToolsOptions,'选项(&O)...');
  ////'&Options...');                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuHelp,'帮助(&H)');
  ////'&Help');                                                                                                                                                                                                            
  cxSetResourceString(@sdxMenuHelpTopics,'帮助主题(&T)...');
  ////'Help &Topics...');                                                                                                                                                                                     
  cxSetResourceString(@sdxMenuHelpAbout,'关于(&A)...');
  ////'&About...');                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuShortcutPreview,'预览');
  ////'Preview');                                                                                                                                                                                                   
  cxSetResourceString(@sdxMenuShortcutAutoText,'自动图文集');
  ////'AutoText');                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuBuiltInMenus,'内置菜单');
  ////'Built-in Menus');                                                                                                                                                                                           
  cxSetResourceString(@sdxMenuShortCutMenus,'快捷菜单');
  ////'Shortcut Menus');                                                                                                                                                                                          
  cxSetResourceString(@sdxMenuNewMenu,'新建菜单');
  ////'New Menu');                                                                                                                                                                                                      
                                                                                                                                                                                                                                                          
  { Hints }                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintFileDesign,'设计报表');
  ////'Design Report');                                                                                                                                                                                              
  cxSetResourceString(@sdxHintFilePrint,'打印');
  ////'Print');                                                                                                                                                                                                           
  cxSetResourceString(@sdxHintFilePrintDialog,'打印对话框');
  ////'Print Dialog');                                                                                                                                                                                        
  cxSetResourceString(@sdxHintFilePageSetup,'页面设置');
  ////'Page Setup');                                                                                                                                                                                              
  cxSetResourceString(@sdxHintFileExit,'关闭预览');
  ////'Close Preview');                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintEditFind,'查找');
  ////'Find');                                                                                                                                                                                                             
  cxSetResourceString(@sdxHintEditFindNext,'查找下一个');
  ////'Find Next');                                                                                                                                                                                              
  cxSetResourceString(@sdxHintEditReplace,'替换');
  ////'Replace');                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintInsertEditAutoTextEntries,'编辑自动图文集');
  ////'Edit AutoText Entries');                                                                                                                                                                 
  cxSetResourceString(@sdxHintInsertPageNumber,'插入页码');
  ////'Insert Page Number');                                                                                                                                                                                   
  cxSetResourceString(@sdxHintInsertTotalPages,'插入页数');
  ////'Insert Number of Pages');                                                                                                                                                                               
  cxSetResourceString(@sdxHintInsertPageOfPages,'插入页范');
  ////'Insert Page Number of Pages');                                                                                                                                                                         
  cxSetResourceString(@sdxHintInsertDateTime,'插入日期和时间');
  ////'Insert Date and Time');                                                                                                                                                                             
  cxSetResourceString(@sdxHintInsertDate,'插入日期');
  ////'Insert Date');                                                                                                                                                                                                
  cxSetResourceString(@sdxHintInsertTime,'插入时间');
  ////'Insert Time');                                                                                                                                                                                                
  cxSetResourceString(@sdxHintInsertUserName,'插入用户名称');
  ////'Insert User Name');                                                                                                                                                                                   
  cxSetResourceString(@sdxHintInsertMachineName,'插入机器名称');
  ////'Insert Machine Name');                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintViewMargins,'查看页边距');
  ////'View Margins');                                                                                                                                                                                            
  cxSetResourceString(@sdxHintViewLargeButtons,'查看大按钮');
  ////'View Large Buttons');                                                                                                                                                                                 
  cxSetResourceString(@sdxHintViewMarginsStatusBar,'查看页边距状态栏');
  ////'View Margins Status Bar');                                                                                                                                                                  
  cxSetResourceString(@sdxHintViewPagesStatusBar,'查看页面状态栏');
  ////'View Page Status Bar');                                                                                                                                                                         
  cxSetResourceString(@sdxHintViewPagesHeaders,'查看页眉');
  ////'View Page Header');                                                                                                                                                                                     
  cxSetResourceString(@sdxHintViewPagesFooters,'查看页脚');
  ////'View Page Footer');                                                                                                                                                                                     
  cxSetResourceString(@sdxHintViewSwitchToLeftPart,'切换到左边的页眉/页脚');
  ////'Switch to Left Header/Footer Part');                                                                                                                                                   
  cxSetResourceString(@sdxHintViewSwitchToRightPart,'切换到右边的页眉/页脚');
  ////'Switch to Right Header/Footer Part');                                                                                                                                                 
  cxSetResourceString(@sdxHintViewSwitchToCenterPart,'切换到中间的页眉/页脚');
  ////'Switch to Center Header/Footer Part');                                                                                                                                               
  cxSetResourceString(@sdxHintViewHFSwitchHeaderFooter,'在页眉和页脚之间切换');
  ////'Switch Between Header and Footer');                                                                                                                                                 
  cxSetResourceString(@sdxHintViewHFClose,'关闭');
  ////'Close');                                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintViewZoom,'缩放');
  ////'Zoom');                                                                                                                                                                                                             
  cxSetResourceString(@sdxHintZoomPercent100,'百分100%');
  ////'Zoom 100%');                                                                                                                                                                                              
  cxSetResourceString(@sdxHintZoomPageWidth,'页宽');
  ////'Zoom Page Width');                                                                                                                                                                                             
  cxSetResourceString(@sdxHintZoomWholePage,'整页');
  ////'Whole Page');                                                                                                                                                                                                  
  cxSetResourceString(@sdxHintZoomTwoPages,'两页');
  ////'Two Pages');                                                                                                                                                                                                    
  cxSetResourceString(@sdxHintZoomFourPages,'四页');
  ////'Four Pages');                                                                                                                                                                                                  
  cxSetResourceString(@sdxHintZoomMultiplyPages,'多页');
  ////'Multiple Pages');                                                                                                                                                                                          
  cxSetResourceString(@sdxHintZoomWidenToSourceWidth,'扩展到原始宽度');
  ////'Widen To Source Width');                                                                                                                                                                    
  cxSetResourceString(@sdxHintZoomSetup,'设置缩放比例');
  ////'Setup Zoom Factor');                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintFormatDateTime,'格式化日期和时间');
  ////'Format Date and Time');                                                                                                                                                                           
  cxSetResourceString(@sdxHintFormatPageNumbering,'格式化页码');
  ////'Format Page Number');                                                                                                                                                                              
  cxSetResourceString(@sdxHintFormatPageBackground,'背景');
  ////'Background');                                                                                                                                                                                           
  cxSetResourceString(@sdxHintFormatShrinkToPage,'缩小适合页面');
  ////'Shrink To Page');                                                                                                                                                                                 
  cxSetResourceString(@sdxHintFormatHFBackground,'页眉/页脚背景');
  ////'Header/Footer Background');                                                                                                                                                                      
  cxSetResourceString(@sdxHintFormatHFClear,'清除页眉/页脚文本');
  ////'Clear Header/Footer Text');                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintGotoPageFirst,'首页');
  ////'First Page');                                                                                                                                                                                                  
  cxSetResourceString(@sdxHintGotoPagePrev,'前一页');
  ////'Previous Page');                                                                                                                                                                                              
  cxSetResourceString(@sdxHintGotoPageNext,'下一页');
  ////'Next Page');                                                                                                                                                                                                  
  cxSetResourceString(@sdxHintGotoPageLast,'尾页');
  ////'Last Page');                                                                                                                                                                                                    
  cxSetResourceString(@sdxHintActivePage,'当前页');
  ////'Active Page');                                                                                                                                                                                                  
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintToolsCustomize,'自定义工具栏');
  ////'Customize Toolbars');                                                                                                                                                                                 
  cxSetResourceString(@sdxHintToolsOptions,'选项');
  ////'Options');                                                                                                                                                                                                      
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintHelpTopics,'帮助主题');
  ////'Help Topics');                                                                                                                                                                                                
  cxSetResourceString(@sdxHintHelpAbout,'关于');
  ////'About');                                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPopupMenuLargeButtons,'大按钮');
  ////'&Large Buttons');                                                                                                                                                                                        
  cxSetResourceString(@sdxPopupMenuFlatButtons,'平面按钮');
  ////'&Flat Buttons');                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPaperSize,'纸张大小');
  ////'Paper Size:');                                                                                                                                                                                                     
  cxSetResourceString(@sdxStatus,'状态');
  ////'Status:');                                                                                                                                                                                                                
  cxSetResourceString(@sdxStatusReady,'就绪');
  ////'Ready');                                                                                                                                                                                                             
  cxSetResourceString(@sdxStatusPrinting,'正在打印。已完成 %d 页');
  ////'Printing. Completed %d page(s)');                                                                                                                                                               
  cxSetResourceString(@sdxStatusGenerateReport,'创建报表。已完成 %d%%');
  ////'Generating Report. Completed %d%%');                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHintDoubleClickForChangePaperSize,'双击改变纸张大小');
  ////'Double Click for Change Paper Size');                                                                                                                                              
  cxSetResourceString(@sdxHintDoubleClickForChangeMargins,'双击改变页边距');
  ////'Double Click for Change Margins');                                                                                                                                                     
                                                                                                                                                                                                                                                          
  { Date&Time Formats Dialog }                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxDTFormatsCaption,'日期与时间');
  ////'Date and Time');                                                                                                                                                                                          
  cxSetResourceString(@sdxDTFormatsAvailableDateFormats,'有效的日期格式:');
  ////'&Available Date Formats:');                                                                                                                                                             
  cxSetResourceString(@sdxDTFormatsAvailableTimeFormats,'有效的时间格式:');
  ////'Available &Time Formats:');                                                                                                                                                             
  cxSetResourceString(@sdxDTFormatsAutoUpdate,'自动更新');
  ////'&Update Automatically');                                                                                                                                                                                 
  cxSetResourceString(@sdxDTFormatsChangeDefaultFormat,                                                                                                                                                                                                                      
    'Do you want to change the default date and time formats to match "%s"  - "%s" ?');                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  { PageNumber Formats Dialog }                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPNFormatsCaption,'页码格式');
  ////'Page Number Format');                                                                                                                                                                                       
  cxSetResourceString(@sdxPageNumbering,'页码');
  ////'Page Numbering');                                                                                                                                                                                                  
  cxSetResourceString(@sdxPNFormatsNumberFormat,'数字格式(&F):');
  ////'Number &Format:');                                                                                                                                                                                
  cxSetResourceString(@sdxPNFormatsContinueFromPrevious,'续前节(&C)');
  ////'&Continue from Previous Section');                                                                                                                                                           
  cxSetResourceString(@sdxPNFormatsStartAt,'起始页码:');
  ////'Start &At:');                                                                                                                                                                                              
  cxSetResourceString(@sdxPNFormatsChangeDefaultFormat,                                                                                                                                                                                                                      
    'Do you want to change the default Page numbering format to match "%s" ?');                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  { Zoom Dialog }                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxZoomDlgCaption,'缩放');
  ////'Zoom');                                                                                                                                                                                                           
  cxSetResourceString(@sdxZoomDlgZoomTo,' 缩放至 ');
  ////' Zoom To ');                                                                                                                                                                                                   
  cxSetResourceString(@sdxZoomDlgPageWidth,'页宽(&W)');
  ////'Page &Width');                                                                                                                                                                                              
  cxSetResourceString(@sdxZoomDlgWholePage,'整页(&H)');
  ////'W&hole Page');                                                                                                                                                                                              
  cxSetResourceString(@sdxZoomDlgTwoPages,'两页(&T)');
  ////'&Two Pages');                                                                                                                                                                                                
  cxSetResourceString(@sdxZoomDlgFourPages,'四页(&F)');
  ////'&Four Pages');                                                                                                                                                                                              
  cxSetResourceString(@sdxZoomDlgManyPages,'多页(&M):');
  ////'&Many Pages:');                                                                                                                                                                                            
  cxSetResourceString(@sdxZoomDlgPercent,'比例:(&E)');
  ////'P&ercent:');                                                                                                                                                                                                 
  cxSetResourceString(@sdxZoomDlgPreview,'预览');
  ////' Preview ');                                                                                                                                                                                                      
  cxSetResourceString(@sdxZoomDlgFontPreview,' 12pt Times New Roman ');
  ////' 12pt Times New Roman ');                                                                                                                                                                   
  cxSetResourceString(@sdxZoomDlgFontPreviewString,'xypxy@163.net');
  ////'AaBbCcDdEeXxYyZz');                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  { Select page X x Y }                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPages,'页');
  ////'Pages');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxCancel,'取消');
  ////'Cancel');                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                          
  { preferences dialog }                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPreferenceDlgCaption,'选项');
  ////'Options');                                                                                                                                                                                                  
  cxSetResourceString(@sdxPreferenceDlgTab1,'常规(&G)');
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
  cxSetResourceString(@sdxPreferenceDlgShow,'显示(&S)');
  ////' &Show ');                                                                                                                                                                                                 
  cxSetResourceString(@sdxPreferenceDlgMargins,'页边距(&M)');
  ////'&Margins ');                                                                                                                                                                                          
  cxSetResourceString(@sdxPreferenceDlgMarginsHints,'页边距提示(&H)');
  ////'Margins &Hints');                                                                                                                                                                            
  cxSetResourceString(@sdxPreferenceDlgMargingWhileDragging,'当拖曳时显示页边距提示(&D)');
  ////'Margins Hints While &Dragging');                                                                                                                                         
  cxSetResourceString(@sdxPreferenceDlgLargeBtns,'大工具栏按钮(&L)');
  ////'&Large Toolbar Buttons');                                                                                                                                                                     
  cxSetResourceString(@sdxPreferenceDlgFlatBtns,'平面工具栏按钮(&F)');
  ////'&Flat Toolbar Buttons');                                                                                                                                                                     
  cxSetResourceString(@sdxPreferenceDlgMarginsColor,'页边距颜色(&C):');
  ////'Margins &Color:');                                                                                                                                                                          
  cxSetResourceString(@sdxPreferenceDlgMeasurementUnits,'度量单位(&U):');
  ////'Measurement &Units:');                                                                                                                                                                    
  cxSetResourceString(@sdxPreferenceDlgSaveForRunTimeToo,'保存设置(&R)');
  ////'Save for &RunTime too');                                                                                                                                                                  
  cxSetResourceString(@sdxPreferenceDlgZoomScroll,'鼠标滚轮控制缩放(&Z)');
  ////'&Zoom on roll with IntelliMouse');                                                                                                                                                       
  cxSetResourceString(@sdxPreferenceDlgZoomStep,'缩放比例(&P):');
  ////'Zoom Ste&p:');                                                                                                                                                                                    
                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  { Page Setup }                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCloneStyleCaptionPrefix,'副本 (%d) / ');
  ////'Copy (%d) of ');                                                                                                                                                                                 
  cxSetResourceString(@sdxInvalideStyleCaption,'样式名称 "%s" 已经存在。 请提供另一个名称。');
  ////'The style name "%s" already exists. Please supply another name.');                                                                                                   
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPageSetupCaption,'页面设置');
  ////'Page Setup');                                                                                                                                                                                               
  cxSetResourceString(@sdxStyleName,'样式名称(&N):');
  ////'Style &Name:');                                                                                                                                                                                               
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPage,'页面(&P)');
  ////'&Page');                                                                                                                                                                                                                
  cxSetResourceString(@sdxMargins,'页边距(&M)');
  ////'&Margins');                                                                                                                                                                                                        
  cxSetResourceString(@sdxHeaderFooter,'页眉/页脚 (&H)');
  ////'&Header\Footer');                                                                                                                                                                                         
  cxSetResourceString(@sdxScaling,'比例(&S)');
  ////'&Scaling');                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPaper,' 纸张 ');
  ////' Paper ');                                                                                                                                                                                                               
  cxSetResourceString(@sdxPaperType,'纸型(&Y)');
  ////'T&ype');                                                                                                                                                                                                           
  cxSetResourceString(@sdxPaperDimension,'尺寸(&S)');
  ////'Dimension');                                                                                                                                                                                                  
  cxSetResourceString(@sdxPaperWidth,'宽度(&W):');
  ////'&Width:');                                                                                                                                                                                                       
  cxSetResourceString(@sdxPaperHeight,'高度(&E):');
  ////'H&eight:');                                                                                                                                                                                                     
  cxSetResourceString(@sdxPaperSource,'纸张来源(&U)');
  ////'Paper so&urce');                                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxOrientation,' 方向');
  ////' Orientation ');                                                                                                                                                                                                    
  cxSetResourceString(@sdxPortrait,'纵向(&O)');
  ////'P&ortrait');                                                                                                                                                                                                        
  cxSetResourceString(@sdxLandscape,'横向(&L)');
  ////'&Landscape');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintOrder,' 打印次序');
  ////' Print Order ');                                                                                                                                                                                                 
  cxSetResourceString(@sdxDownThenOver,'先列后行(&D)');
  ////'&Down, then over');                                                                                                                                                                                         
  cxSetResourceString(@sdxOverThenDown,'先行后列(&V)');
  ////'O&ver, then down');                                                                                                                                                                                         
  cxSetResourceString(@sdxShading,' 阴影 ');
  ////' Shading ');                                                                                                                                                                                                           
  cxSetResourceString(@sdxPrintUsingGrayShading,'使用灰色阴影打印(&G)');
  ////'Print using &gray shading');                                                                                                                                                               
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCenterOnPage,'居中方式');
  ////'Center on page');                                                                                                                                                                                               
  cxSetResourceString(@sdxHorizontally,'水平(&Z)');
  ////'Hori&zontally');                                                                                                                                                                                                
  cxSetResourceString(@sdxVertically,'垂直(&V)');
  ////'&Vertically');                                                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxHeader,'页眉 ');
  ////'Header ');                                                                                                                                                                                                               
  cxSetResourceString(@sdxBtnHeaderFont,'字体(&F)...');
  ////'&Font...');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnHeaderBackground,'背景(&B)');
  ////'&Background');                                                                                                                                                                                           
  cxSetResourceString(@sdxFooter,'页脚 ');
  ////'Footer ');                                                                                                                                                                                                               
  cxSetResourceString(@sdxBtnFooterFont,'字体(&N)...');
  ////'Fo&nt...');                                                                                                                                                                                                 
  cxSetResourceString(@sdxBtnFooterBackground,'背景(&G)');
  ////'Back&ground');                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxTop,'上(&T):');
  ////'&Top:');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxLeft,'左(&L):');
  ////'&Left:');                                                                                                                                                                                                                
  cxSetResourceString(@sdxRight,'右(&G):');
  ////'Ri&ght:');                                                                                                                                                                                                              
  cxSetResourceString(@sdxBottom,'下(&B):');
  ////'&Bottom:');                                                                                                                                                                                                            
  cxSetResourceString(@sdxHeader2,'页眉(&E):');
  ////'H&eader:');                                                                                                                                                                                                         
  cxSetResourceString(@sdxFooter2,'页脚(&R):');
  ////'Foote&r:');                                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxAlignment,'对齐方式');
  ////'Alignment');                                                                                                                                                                                                       
  cxSetResourceString(@sdxVertAlignment,' 垂直对齐');
  ////' Vertical Alignment ');                                                                                                                                                                                       
  cxSetResourceString(@sdxReverseOnEvenPages,'偶页相反(&R)');
  ////'&Reverse on even pages');                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxAdjustTo,'调整到:');
  ////'&Adjust To:');                                                                                                                                                                                                       
  cxSetResourceString(@sdxFitTo,'适合:');
  ////'&Fit To:');                                                                                                                                                                                                               
  cxSetResourceString(@sdxPercentOfNormalSize,'% 正常大小');
  ////'% normal size');                                                                                                                                                                                       
  cxSetResourceString(@sdxPagesWideBy,'页宽(&W)');
  ////'page(s) &wide by');                                                                                                                                                                                              
  cxSetResourceString(@sdxTall,'页高(&T)');
  ////'&tall');                                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxOf,'共');
  ////'Of');                                                                                                                                                                                                                           
  cxSetResourceString(@sdxLastPrinted,'上次打印时间 ');
  ////'Last Printed ');                                                                                                                                                                                            
  cxSetResourceString(@sdxFileName,'文件名称 ');
  ////'Filename ');                                                                                                                                                                                                       
  cxSetResourceString(@sdxFileNameAndPath,'文件名称和路径 ');
  ////'Filename and path ');                                                                                                                                                                                 
  cxSetResourceString(@sdxPrintedBy,'打印由 ');
  ////'Printed By ');                                                                                                                                                                                                      
  cxSetResourceString(@sdxPrintedOn,'打印在 ');
  ////'Printed On ');                                                                                                                                                                                                      
  cxSetResourceString(@sdxCreatedBy,'创建由 ');
  ////'Created By ');                                                                                                                                                                                                      
  cxSetResourceString(@sdxCreatedOn,'创建在 ');
  ////'Created On ');                                                                                                                                                                                                      
  cxSetResourceString(@sdxConfidential,'机密');
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
  
  cxSetResourceString(@sdxJanuary,'一月');
  ////'January');                                                                                                                                                                                                               
  cxSetResourceString(@sdxFebruary,'二月');
  ////'February');                                                                                                                                                                                                             
  cxSetResourceString(@sdxMarch,'三月');
  ////'March');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxApril,'四月');
  ////'April');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxMay,'五月');
  ////'May');                                                                                                                                                                                                                       
  cxSetResourceString(@sdxJune,'六月');
  ////'June');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxJuly,'七月');
  ////'July');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxAugust,'八月');
  ////'August');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxSeptember,'九月');
  ////'September');                                                                                                                                                                                                           
  cxSetResourceString(@sdxOctober,'十月');
  ////'October');                                                                                                                                                                                                               
  cxSetResourceString(@sdxNovember,'十一月');
  ////'November');                                                                                                                                                                                                           
  cxSetResourceString(@sdxDecember,'十二月');
  ////'December');                                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxEast,'东方');
  ////'East');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxWest,'西方');
  ////'West');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxSouth,'南方');
  ////'South');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxNorth,'北方');
  ////'North');                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxTotal,'合计');
  ////'Total');                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  { dxFlowChart }                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPlan,'设计图');
  ////'Plan');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxSwimmingPool,'游泳池');
  ////'Swimming-pool');                                                                                                                                                                                                  
  cxSetResourceString(@sdxAdministration,'管理员');
  ////'Administration');                                                                                                                                                                                               
  cxSetResourceString(@sdxPark,'公园');
  ////'Park');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxCarParking,'停车场');
  ////'Car-Parking');                                                                                                                                                                                                      
                                                                                                                                                                                                                                                          
  { dxOrgChart }                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCorporateHeadquarters,'公司'+#13#10+'总部');
  ////'Corporate' + #13#10 + 'Headquarters');                                                                                                                                                       
  cxSetResourceString(@sdxSalesAndMarketing,'销售部'+#13#10+'市场部');
  ////'Sales and' + #13#10 + 'Marketing');                                                                                                                                                          
  cxSetResourceString(@sdxEngineering,'工程技术部');
  ////'Engineering');                                                                                                                                                                                                 
  cxSetResourceString(@sdxFieldOfficeCanada,'办公室:'+#13#10+'加拿大');
  ////'Field Office:' + #13#10 + 'Canada');                                                                                                                                                        
                                                                                                                                                                                                                                                          
  { dxMasterView }                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxOrderNoCaption,'序号');
  ////'OrderNo');                                                                                                                                                                                                        
  cxSetResourceString(@sdxNameCaption,'名称');
  ////'Name');                                                                                                                                                                                                              
  cxSetResourceString(@sdxCountCaption,'数量');
  ////'Count');                                                                                                                                                                                                            
  cxSetResourceString(@sdxCompanyCaption,'公司');
  ////'Company');                                                                                                                                                                                                        
  cxSetResourceString(@sdxAddressCaption,'地址');
  ////'Address');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPriceCaption,'价格');
  ////'Price');                                                                                                                                                                                                            
  cxSetResourceString(@sdxCashCaption,'现金');
  ////'Cash');                                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxName1,'张三');
  ////'Jennie Valentine');                                                                                                                                                                                                        
  cxSetResourceString(@sdxName2,'李四');
  ////'Sam Hill');                                                                                                                                                                                                                
  cxSetResourceString(@sdxCompany1,'宇宙有限公司');
  ////'Jennie Inc.');                                                                                                                                                                                                  
  cxSetResourceString(@sdxCompany2,'地球集团');
  ////'Daimler-Chrysler AG');                                                                                                                                                                                              
  cxSetResourceString(@sdxAddress1,'123 Home Lane');
  ////'123 Home Lane');                                                                                                                                                                                               
  cxSetResourceString(@sdxAddress2,'9333 Holmes Dr.');
  ////'9333 Holmes Dr.');                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  { dxTreeList }                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCountIs,'数量：%d');
  ////'Count is: %d');                                                                                                                                                                                                      
  cxSetResourceString(@sdxRegular,'常规');
  ////'Regular');                                                                                                                                                                                                               
  cxSetResourceString(@sdxIrregular,'不规则');
  ////'Irregular');                                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxTLBand,'项目数据');
  ////'Item Data');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTLColumnName,'名称');
  ////'Name');                                                                                                                                                                                                             
  cxSetResourceString(@sdxTLColumnAxisymmetric,'轴对称');
  ////'Axisymmetric');                                                                                                                                                                                           
  cxSetResourceString(@sdxTLColumnItemShape,'形状');
  ////'Shape');                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxItemShapeAsText,'(图形)');
  ////'(Graphic)');                                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxItem1Name,'锥形物');
  ////'Cylinder');                                                                                                                                                                                                          
  cxSetResourceString(@sdxItem2Name,'圆柱体');
  ////'Cone');                                                                                                                                                                                                              
  cxSetResourceString(@sdxItem3Name,'棱锥');
  ////'Pyramid');                                                                                                                                                                                                             
  cxSetResourceString(@sdxItem4Name,'盒子');
  ////'Box');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxItem5Name,'自由表面');
  ////'Free Surface');                                                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxItem1Description,'');
  ////'');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxItem2Description,'轴对称几何图形');
  ////'Axisymmetric geometry figure');                                                                                                                                                                       
  cxSetResourceString(@sdxItem3Description,'轴对称几何图形');
  ////'Axisymmetric geometry figure');                                                                                                                                                                       
  cxSetResourceString(@sdxItem4Description,'锐角几何图形');
  ////'Acute-angled geometry figure');                                                                                                                                                                         
  cxSetResourceString(@sdxItem5Description,'');
  ////'');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxItem6Description,'');
  ////'');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxItem7Description,'简单突出表面');
  ////'Simple extrusion surface');                                                                                                                                                                             
                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  { PS 2.3 }                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  { Patterns common }                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxPatternIsNotRegistered,'模式 "%s" 没有注册');
  ////'Pattern "%s" is not registered');                                                                                                                                                           
                                                                                                                                                                                                                                                          
  { Excel edge patterns }                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxSolidEdgePattern,'实线');
  ////'Solid');                                                                                                                                                                                                        
  cxSetResourceString(@sdxThinSolidEdgePattern,'细实线');
  ////'Medium Solid');                                                                                                                                                                                           
  cxSetResourceString(@sdxMediumSolidEdgePattern,'中实线');
  ////'Medium Solid');                                                                                                                                                                                         
  cxSetResourceString(@sdxThickSolidEdgePattern,'粗实线');
  ////'Thick Solid');                                                                                                                                                                                           
  cxSetResourceString(@sdxDottedEdgePattern,'圆点');
  ////'Dotted');                                                                                                                                                                                                      
  cxSetResourceString(@sdxDashedEdgePattern,'短画线');
  ////'Dashed');                                                                                                                                                                                                    
  cxSetResourceString(@sdxDashDotDotEdgePattern,'短画线-点-点');
  ////'Dash Dot Dot');                                                                                                                                                                                    
  cxSetResourceString(@sdxDashDotEdgePattern,'短画线-点');
  ////'Dash Dot');                                                                                                                                                                                              
  cxSetResourceString(@sdxSlantedDashDotEdgePattern,'斜短画线-点');
  ////'Slanted Dash Dot');                                                                                                                                                                             
  cxSetResourceString(@sdxMediumDashDotDotEdgePattern,'中等短画线-点-点');
  ////'Medium Dash Dot Dot');                                                                                                                                                                   
  cxSetResourceString(@sdxHairEdgePattern,'丝状');
  ////'Hair');                                                                                                                                                                                                          
  cxSetResourceString(@sdxMediumDashDotEdgePattern,'中等短画线-点');
  ////'Medium Dash Dot');                                                                                                                                                                             
  cxSetResourceString(@sdxMediumDashedEdgePattern,'中等短画线');
  ////'Medium Dashed');                                                                                                                                                                                   
  cxSetResourceString(@sdxDoubleLineEdgePattern,'双线');
  ////'Double Line');                                                                                                                                                                                             
                                                                                                                                                                                                                                                          
  { Excel fill patterns names}                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxSolidFillPattern,'原色');
  ////'Solid');                                                                                                                                                                                                        
  cxSetResourceString(@sdxGray75FillPattern,'75% 灰色');
  ////'75% Gray');                                                                                                                                                                                                
  cxSetResourceString(@sdxGray50FillPattern,'50% 灰色');
  ////'50% Gray');                                                                                                                                                                                                
  cxSetResourceString(@sdxGray25FillPattern,'25% 灰色');
  ////'25% Gray');                                                                                                                                                                                                
  cxSetResourceString(@sdxGray125FillPattern,'12.5% 灰色');
  ////'12.5% Gray');                                                                                                                                                                                           
  cxSetResourceString(@sdxGray625FillPattern,'6.25% 灰色');
  ////'6.25% Gray');                                                                                                                                                                                           
  cxSetResourceString(@sdxHorizontalStripeFillPattern,'水平条纹');
  ////'Horizontal Stripe');                                                                                                                                                                             
  cxSetResourceString(@sdxVerticalStripeFillPattern,'垂直条纹');
  ////'Vertical Stripe');                                                                                                                                                                                 
  cxSetResourceString(@sdxReverseDiagonalStripeFillPattern,'逆对角线条纹');
  ////'Reverse Diagonal Stripe');                                                                                                                                                              
  cxSetResourceString(@sdxDiagonalStripeFillPattern,'对角线条纹');
  ////'Diagonal Stripe');                                                                                                                                                                               
  cxSetResourceString(@sdxDiagonalCrossHatchFillPattern,'对角线剖面线');
  ////'Diagonal Cross Hatch');                                                                                                                                                                    
  cxSetResourceString(@sdxThickCrossHatchFillPattern,'粗对角线剖面线');
  ////'Thick Cross Hatch');                                                                                                                                                                        
  cxSetResourceString(@sdxThinHorizontalStripeFillPattern,'细水平条纹');
  ////'Thin Horizontal Stripe');                                                                                                                                                                  
  cxSetResourceString(@sdxThinVerticalStripeFillPattern,'细垂直条纹');
  ////'Thin Vertical Stripe');                                                                                                                                                                      
  cxSetResourceString(@sdxThinReverseDiagonalStripeFillPattern,'Thin Reverse Diagonal Stripe');                                                                                                                                                                               
  cxSetResourceString(@sdxThinDiagonalStripeFillPattern,'细对角线条纹');
  ////'Thin Diagonal Stripe');                                                                                                                                                                    
  cxSetResourceString(@sdxThinHorizontalCrossHatchFillPattern,'细水平剖面线');
  ////'Thin Horizontal Cross Hatch');                                                                                                                                                       
  cxSetResourceString(@sdxThinDiagonalCrossHatchFillPattern,'细对角线剖面线');
  ////'Thin Diagonal Cross Hatch');                                                                                                                                                         
                                                                                                                                                                                                                                                          
  { cxSpreadSheet }                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxShowRowAndColumnHeadings,'行和列标题(&R)');
  ////'&Row and Column Headings');                                                                                                                                                                   
  cxSetResourceString(@sdxShowGridLines,'网格行');
  ////'GridLines');                                                                                                                                                                                                     
  cxSetResourceString(@sdxSuppressSourceFormats,'禁止源格式(&S)');
  ////'&Suppress Source Formats');                                                                                                                                                                      
  cxSetResourceString(@sdxRepeatHeaderRowAtTop,'在顶端重复标题行');
  ////'Repeat Header Row at Top');                                                                                                                                                                     
  cxSetResourceString(@sdxDataToPrintDoesNotExist,                                                                                                                                                                                                                           
    'Cannot activate ReportLink because PrintingSystem did not find anything to print.');                                                                                                                                                                  
                                                                                                                                                                                                                                                          
  { Designer strings }                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  { Short names of month }                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxJanuaryShort,'一月');
  ////'Jan');                                                                                                                                                                                                              
  cxSetResourceString(@sdxFebruaryShort,'二月');
  ////'Feb');                                                                                                                                                                                                             
  cxSetResourceString(@sdxMarchShort,'三月');
  ////'March');                                                                                                                                                                                                              
  cxSetResourceString(@sdxAprilShort,'四月');
  ////'April');                                                                                                                                                                                                              
  cxSetResourceString(@sdxMayShort,'五月');
  ////'May');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxJuneShort,'六月');
  ////'June');                                                                                                                                                                                                                
  cxSetResourceString(@sdxJulyShort,'七月');
  ////'July');                                                                                                                                                                                                                
  cxSetResourceString(@sdxAugustShort,'八月');
  ////'Aug');                                                                                                                                                                                                               
  cxSetResourceString(@sdxSeptemberShort,'九月');
  ////'Sept');                                                                                                                                                                                                           
  cxSetResourceString(@sdxOctoberShort,'十月');
  ////'Oct');                                                                                                                                                                                                              
  cxSetResourceString(@sdxNovemberShort,'十一月');
  ////'Nov');                                                                                                                                                                                                           
  cxSetResourceString(@sdxDecemberShort,'十二月');
  ////'Dec');                                                                                                                                                                                                           
                                                                                                                                                                                                                                                          
  { TreeView }                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxTechnicalDepartment,'技术部门');
  ////'Technical Department');                                                                                                                                                                                  
  cxSetResourceString(@sdxSoftwareDepartment,'软件部门');
  ////'Software Department');                                                                                                                                                                                    
  cxSetResourceString(@sdxSystemProgrammers,'系统程序员');
  ////'Core Developers');                                                                                                                                                                                       
  cxSetResourceString(@sdxEndUserProgrammers,'终端用户程序员');
  ////'GUI Developers');                                                                                                                                                                                   
  cxSetResourceString(@sdxBetaTesters,'测试员');
  ////'Beta Testers');                                                                                                                                                                                                    
  cxSetResourceString(@sdxHumanResourceDepartment,'人力资源部门');
  ////'Human Resource Department');                                                                                                                                                                     
                                                                                                                                                                                                                                                          
  { misc. }                                                                                                                                                                                                                                               
  cxSetResourceString(@sdxTreeLines,'树线');
  ////'&TreeLines');                                                                                                                                                                                                          
  cxSetResourceString(@sdxTreeLinesColor,'树线颜色:');
  ////'T&ree Line Color:');                                                                                                                                                                                         
  cxSetResourceString(@sdxExpandButtons,'展开按钮');
  ////'E&xpand Buttons');                                                                                                                                                                                             
  cxSetResourceString(@sdxCheckMarks,'检查标记');
  ////'Check Marks');                                                                                                                                                                                                    
  cxSetResourceString(@sdxTreeEffects,'树效果');
  ////'Tree Effects');                                                                                                                                                                                                    
  cxSetResourceString(@sdxAppearance,'外观');
  ////'Appearance');                                                                                                                                                                                                         
                                                                                                                                                                                                                                                          
  { Designer previews }                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  { Localize if you want (they are used inside FormatReport dialog -> ReportPreview) }                                                                                                                                                                    
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCarLevelCaption,'汽车');
  ////'Cars');                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxManufacturerBandCaption,'Manufacturer Data');                                                                                                                                                                                                       
  cxSetResourceString(@sdxModelBandCaption,'汽车数据');
  ////'Car Data');                                                                                                                                                                                                 
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxManufacturerNameColumnCaption,'Name');                                                                                                                                                                                                              
  cxSetResourceString(@sdxManufacturerLogoColumnCaption,'Logo');                                                                                                                                                                                                              
  cxSetResourceString(@sdxManufacturerCountryColumnCaption,'Country');                                                                                                                                                                                                        
  cxSetResourceString(@sdxCarModelColumnCaption,'模型');
  ////'Model');                                                                                                                                                                                                   
  cxSetResourceString(@sdxCarIsSUVColumnCaption,'SUV');
  ////'SUV');                                                                                                                                                                                                      
  cxSetResourceString(@sdxCarPhotoColumnCaption,'照片');
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
  cxSetResourceString(@sdxCarModel2,'旅行');
  ////'Excursion');                                                                                                                                                                                                           
  cxSetResourceString(@sdxCarModel3,'S8 Quattro');
  ////'S8 Quattro');                                                                                                                                                                                                    
  cxSetResourceString(@sdxCarModel4,'G4 挑战');
  ////'G4 Challenge');                                                                                                                                                                                                     
                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxTrue,'真');
  ////'True');                                                                                                                                                                                                                       
  cxSetResourceString(@sdxFalse,'假');
  ////'False');                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                          
  { PS 2.4 }                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  { dxPrnDev.pas }                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxAuto,'自动');
  ////'Auto');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxCustom,'常规');
  ////'Custom');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxEnv,'Env');
  ////'Env');                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                          
  { Grid 4 }                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxLookAndFeelFlat,'平面');
  ////'Flat');                                                                                                                                                                                                          
  cxSetResourceString(@sdxLookAndFeelStandard,'标准');
  ////'Standard');                                                                                                                                                                                                  
  cxSetResourceString(@sdxLookAndFeelUltraFlat,'超平面');
  ////'UltraFlat');                                                                                                                                                                                              
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxViewTab,'视图');
  ////'View');                                                                                                                                                                                                                  
  cxSetResourceString(@sdxBehaviorsTab,'性能');
  ////'Behaviors');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPreviewTab,'预览');
  ////'Preview');                                                                                                                                                                                                            
  cxSetResourceString(@sdxCardsTab,'卡片');
  ////'Cards');                                                                                                                                                                                                                
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxFormatting,'格式');
  ////'Formatting');                                                                                                                                                                                                         
  cxSetResourceString(@sdxLookAndFeel,'外观');
  ////'Look and Feel');                                                                                                                                                                                                     
  cxSetResourceString(@sdxLevelCaption,'标题');
  ////'&Caption');                                                                                                                                                                                                         
  cxSetResourceString(@sdxFilterBar,'过滤器状态条');
  ////'&Filter Bar');                                                                                                                                                                                                 
  cxSetResourceString(@sdxRefinements,'修正');
  ////'Refinements');                                                                                                                                                                                                       
  cxSetResourceString(@sdxProcessSelection,'处理选择(&S)');
  ////'Process &Selection');                                                                                                                                                                                   
  cxSetResourceString(@sdxProcessExactSelection,'处理精确选择(&X)');
  ////'Process E&xact Selection');                                                                                                                                                                    
  cxSetResourceString(@sdxExpanding,'扩充');
  ////'Expanding');                                                                                                                                                                                                           
  cxSetResourceString(@sdxGroups,'组(&G)');
  ////'&Groups');                                                                                                                                                                                                              
  cxSetResourceString(@sdxDetails,'细节(&D)');
  ////'&Details');                                                                                                                                                                                                          
  cxSetResourceString(@sdxStartFromActiveDetails,'从当前细节开始');
  ////'Start from Active Details');                                                                                                                                                                    
  cxSetResourceString(@sdxOnlyActiveDetails,'仅含当前细节');
  ////'Only Active Details');                                                                                                                                                                                 
  cxSetResourceString(@sdxVisible,'可见(&V)');
  ////'&Visible');                                                                                                                                                                                                          
  cxSetResourceString(@sdxPreviewAutoHeight,'自动高度(&U)');
  ////'A&uto Height');                                                                                                                                                                                        
  cxSetResourceString(@sdxPreviewMaxLineCount,'最大行计算(&M)： ');
  ////'&Max Line Count: ');                                                                                                                                                                            
  cxSetResourceString(@sdxSizes,'大小');
  ////'Sizes');                                                                                                                                                                                                                   
  cxSetResourceString(@sdxKeepSameWidth,'保持同样宽度(&K)');
  ////'&Keep Same Width');                                                                                                                                                                                    
  cxSetResourceString(@sdxKeepSameHeight,'保持同样高度(&H)');
  ////'Keep Same &Height');                                                                                                                                                                                  
  cxSetResourceString(@sdxFraming,'框架');
  ////'Framing');                                                                                                                                                                                                               
  cxSetResourceString(@sdxSpacing,'间距');
  ////'Spacing');                                                                                                                                                                                                               
  cxSetResourceString(@sdxShadow,'阴影');
  ////'Shadow');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxDepth,'浓度(&D):');
  ////'&Depth:');                                                                                                                                                                                                            
  cxSetResourceString(@sdxPosition,'位置(&P)');
  ////'&Position');                                                                                                                                                                                                        
  cxSetResourceString(@sdxPositioning,'位置');
  ////'Positioning');                                                                                                                                                                                                       
  cxSetResourceString(@sdxHorizontal,'水平(&O):');
  ////'H&orizontal:');                                                                                                                                                                                                  
  cxSetResourceString(@sdxVertical,'垂直(&E):');
  ////'V&ertical:');                                                                                                                                                                                                      
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxSummaryFormat,'计数,0');
  ////'Count,0');                                                                                                                                                                                                   
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxCannotUseOnEveryPageMode,'不能使用在每页方式'+#13#10+
  ////'Cannot Use OnEveryPage Mode'+ #13#10 +                                                                                                                                            
    #13#10 +                                                                                                                                                                                                                                              
    'You should or(and)' + #13#10 +                                                                                                                                                                                                                       
    '  - Collapse all Master Records' + #13#10 +                                                                                                                                                                                                          
    '  - Toggle "Unwrap" Option off on "Behaviors" Tab');                                                                                                                                                                                                  
                                                                                                                                                                                                                                                          
  cxSetResourceString(@sdxIncorrectBandHeadersState,'不能使用带区报头在每一页方式'+#13#10+
  ////'Cannot Use BandHeaders OnEveryPage Mode' + #13#10 +                                                                                                                    
    #13#10 +                                                                                                                                                                                                                                              
    'You should either:' + #13#10 +                                                                                                                                                                                                                       
    '  - Set Caption OnEveryPage Option On' + #13#10 +                                                                                                                                                                                                    
    '  - Set Caption Visible Option Off');                                                                                                                                                                                                                 
  cxSetResourceString(@sdxIncorrectHeadersState,'不能使用报头在每一页方式'+#13#10+
  ////'Cannot Use Headers OnEveryPage Mode' + #13#10 +                                                                                                                                
    #13#10 +                                                                                                                                                                                                                                              
    'You should either:' + #13#10 +                                                                                                                                                                                                                       
    '  - Set Caption and Band OnEveryPage Option On' + #13#10 +                                                                                                                                                                                           
    '  - Set Caption and Band Visible Option Off');                                                                                                                                                                                                        
  cxSetResourceString(@sdxIncorrectFootersState,'不能使用页脚在每一页方式'+#13#10+
  ////'Cannot Use Footers OnEveryPage Mode' + #13#10 +                                                                                                                                
    #13#10 +                                                                                                                                                                                                                                              
    'You should either:' + #13#10 +                                                                                                                                                                                                                       
    '  - Set FilterBar OnEveryPage Option On' + #13#10 +                                                                                                                                                                                                  
    '  - Set FilterBar Visible Option Off');

  cxSetResourceString(@sdxCharts,'图表');
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

  cxSetResourceString(@sdxHalf,'一半');
  ////'Half');                                                                                                                                                                                                                     
  cxSetResourceString(@sdxPredefinedFunctions,'预定义函数'); // dxPgsDlg.pas
  ////' Predefined Functions '); // dxPgsDlg.pas                                                                                                                                              
  cxSetResourceString(@sdxZoomParameters,'缩放参数(&P)');          // dxPSPrvwOpt.pas
  ////' Zoom &Parameters ');          // dxPSPrvwOpt.pas                                                                                                                             

  cxSetResourceString(@sdxWrapData,'包装数据');
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

 { cxSetResourceString(@sdxSize,'大小');
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
  cxSetResourceString(@dxSBAR_LOOKUPDIALOGCAPTION , '选择值');
  cxSetResourceString(@dxSBAR_LOOKUPDIALOGOK , '确定');
  cxSetResourceString(@dxSBAR_LOOKUPDIALOGCANCEL , '返回');

  cxSetResourceString(@dxSBAR_DIALOGOK , '确定');
  cxSetResourceString(@dxSBAR_DIALOGCANCEL , '返回');
  cxSetResourceString(@dxSBAR_COLOR_STR_0 , '黑色');
  cxSetResourceString(@dxSBAR_COLOR_STR_1 , '栗色');
  cxSetResourceString(@dxSBAR_COLOR_STR_2 , '绿色');
  cxSetResourceString(@dxSBAR_COLOR_STR_3 , '橄榄色');
  cxSetResourceString(@dxSBAR_COLOR_STR_4 , '藏青色');
  cxSetResourceString(@dxSBAR_COLOR_STR_5 , '紫色');
  cxSetResourceString(@dxSBAR_COLOR_STR_6 , '茶色');
  cxSetResourceString(@dxSBAR_COLOR_STR_7 , '灰色');
  cxSetResourceString(@dxSBAR_COLOR_STR_8 , '银色');
  cxSetResourceString(@dxSBAR_COLOR_STR_9 , '红色');
  cxSetResourceString(@dxSBAR_COLOR_STR_10 , '灰白色');
  cxSetResourceString(@dxSBAR_COLOR_STR_11 , '黄色');
  cxSetResourceString(@dxSBAR_COLOR_STR_12 , '蓝色');
  cxSetResourceString(@dxSBAR_COLOR_STR_13 , '紫红色');
  cxSetResourceString(@dxSBAR_COLOR_STR_14 , '浅绿色');
  cxSetResourceString(@dxSBAR_COLOR_STR_15 , '白色');
  cxSetResourceString(@dxSBAR_COLORAUTOTEXT , '(自动)');
  cxSetResourceString(@dxSBAR_COLORCUSTOMTEXT , '(自定义)');
  cxSetResourceString(@dxSBAR_DATETODAY , '今天');
  cxSetResourceString(@dxSBAR_DATECLEAR , '清空');
  cxSetResourceString(@dxSBAR_DATEDIALOGCAPTION , '日期选择');
  cxSetResourceString(@dxSBAR_TREEVIEWDIALOGCAPTION , '项目选择');
  cxSetResourceString(@dxSBAR_IMAGEDIALOGCAPTION , '项目选择');
  cxSetResourceString(@dxSBAR_IMAGEINDEX , '图象索引');
  cxSetResourceString(@dxSBAR_IMAGETEXT , '文本');
  cxSetResourceString(@dxSBAR_PLACEFORCONTROL , '位置至于 ');
  cxSetResourceString(@dxSBAR_CANTASSIGNCONTROL , '你无法分配相同的控制给更多的TdxBarControlContainerItem.');
  cxSetResourceString(@dxSBAR_CXEDITVALUEDIALOGCAPTION, '输入值');

  cxSetResourceString(@dxSBAR_WANTTORESETTOOLBAR , '你确定重新设置已被改变配制的工具栏''%s''?');
  cxSetResourceString(@dxSBAR_WANTTORESETUSAGEDATA , '将会删除命令记录并请求和恢复默认的菜单和工具栏可见命令设置. 它将会被取消与外在的定制.   你确定继续?');
  cxSetResourceString(@dxSBAR_BARMANAGERMORETHANONE  , '一个Form应该只有一个唯一的TdxBarManager');
  cxSetResourceString(@dxSBAR_BARMANAGERBADOWNER , 'TdxBarManager应该有它自已的 - TForm (TCustomForm)');
  cxSetResourceString(@dxSBAR_NOBARMANAGERS , '那里没有可用的TdxBarManagers');
  cxSetResourceString(@dxSBAR_WANTTODELETETOOLBAR , '你确定要删除这个工具栏''%s''?');
  cxSetResourceString(@dxSBAR_WANTTODELETECATEGORY , '你确定要删除这个种类''%s''?');
  cxSetResourceString(@dxSBAR_WANTTOCLEARCOMMANDS , '你确定要删除这个种类所有的命令''%s''?');
  cxSetResourceString(@dxSBAR_RECURSIVEMENUS , '你无法创建递归的子项目');
  cxSetResourceString(@dxSBAR_COMMANDNAMECANNOTBEBLANK , '命令名称不能为空. 请输入一个名称.');
  cxSetResourceString(@dxSBAR_TOOLBAREXISTS , '被指定的工具栏已经存在 ''%s'' . 请重新命名.');
  cxSetResourceString(@dxSBAR_RECURSIVEGROUPS , '你无法创建递归的组');
  cxSetResourceString(@dxSBAR_WANTTODELETECOMPLEXITEM, '一个选中的对象有几个对应的链接，是否删除这些链接？');
  cxSetResourceString(@dxSBAR_CANTPLACEQUICKACCESSGROUPBUTTON, '你只能将TdxRibbonQuickAccessGroupButton放置在TdxRibbonQuickAccessToolbar处');
  cxSetResourceString(@dxSBAR_QUICKACCESSGROUPBUTTONTOOLBARNOTDOCKEDINRIBBON, '快速工具栏不能停放在Ribbon');
  cxSetResourceString(@dxSBAR_QUICKACCESSALREADYHASGROUPBUTTON, '快速工具栏已经包含相同的Toolbar');
  cxSetResourceString(@dxSBAR_CANTPLACESEPARATOR, '项目不能放置在指定的Toolbar上');
  cxSetResourceString(@dxSBAR_CANTPLACERIBBONGALLERY, '你只能将TdxRibbonGalleryItem放置到Ribbon上');


  cxSetResourceString(@dxSBAR_CANTMERGEBARMANAGER , 'You cannot merge with the specified bar manager');
  cxSetResourceString(@dxSBAR_CANTMERGETOOLBAR , 'You cannot merge with the specified toolbar');
  cxSetResourceString(@dxSBAR_CANTMERGEWITHMERGEDTOOLBAR , 'You cannot merge a toolbar with a toolbar that is already merged');
  cxSetResourceString(@dxSBAR_CANTUNMERGETOOLBAR , 'You cannot unmerge the specified toolbar');
  cxSetResourceString(@dxSBAR_ONEOFTOOLBARSALREADYMERGED , 'One of the toolbars of the specified bar manager is already merged');
  cxSetResourceString(@dxSBAR_ONEOFTOOLBARSHASMERGEDTOOLBARS , 'One of the toolbars of the specified bar manager has merged toolbars');
  cxSetResourceString(@dxSBAR_TOOLBARHASMERGEDTOOLBARS , 'The ''%s'' toolbar has merged toolbars');
  cxSetResourceString(@dxSBAR_TOOLBARSALREADYMERGED , 'The ''%s'' toolbar is already merged with the ''%s'' toolbar');
  cxSetResourceString(@dxSBAR_TOOLBARSARENOTMERGED , 'The ''%s'' toolbar is not merged with the ''%s'' toolbar');


  cxSetResourceString(@dxSBAR_DEFAULTCATEGORYNAME , '默认');
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

  cxSetResourceString(@dxSBAR_CP_ADDSUBITEM , '添加子项目(&S)');
  cxSetResourceString(@dxSBAR_CP_ADDBUTTON , '添加按钮(&B)');
//  cxSetResourceString(@dxSBAR_CP_ADDITEM , '添加项目(&I)');
//  cxSetResourceString(@dxSBAR_CP_DELETEBAR , '删除栏');

  cxSetResourceString(@dxSBAR_CP_RESET , '重新设置(&R)');
  cxSetResourceString(@dxSBAR_CP_DELETE , '删除(&D)');
  cxSetResourceString(@dxSBAR_CP_NAME , '名称(&N):');
  cxSetResourceString(@dxSBAR_CP_CAPTION , '标题(&C):'); // is the same as dxSBAR_CP_NAME (at design-time)
  cxSetResourceString(@dxSBAR_CP_BUTTONPAINTSTYLEMENU, '按钮类型(&s)');
  cxSetResourceString(@dxSBAR_CP_DEFAULTSTYLE , '默认类型(&U)');
  cxSetResourceString(@dxSBAR_CP_TEXTONLYALWAYS , '唯一文本(始终)(&T)');
  cxSetResourceString(@dxSBAR_CP_TEXTONLYINMENUS , '唯一文本(在菜单)(&O)');
  cxSetResourceString(@dxSBAR_CP_IMAGEANDTEXT , '图像和文本(&A)');
  cxSetResourceString(@dxSBAR_CP_BEGINAGROUP , '开始一个组(&G)');
  cxSetResourceString(@dxSBAR_CP_VISIBLE , '可见的(&V)');
  cxSetResourceString(@dxSBAR_CP_MOSTRECENTLYUSED , '大部分最近使用过的(&M)');
  // begin DesignTime section
  cxSetResourceString(@dxSBAR_CP_POSITIONMENU , '&Position');
  cxSetResourceString(@dxSBAR_CP_VIEWLEVELSMENU , 'View&Levels');
  cxSetResourceString(@dxSBAR_CP_ALLVIEWLEVELS , 'All');
  cxSetResourceString(@dxSBAR_CP_SINGLEVIEWLEVELITEMSUFFIX , ' ONLY');
  cxSetResourceString(@dxSBAR_CP_BUTTONGROUPMENU , 'ButtonG&roup');
  cxSetResourceString(@dxSBAR_CP_BUTTONGROUP , 'Group');
  cxSetResourceString(@dxSBAR_CP_BUTTONUNGROUP , 'Ungroup');
  // end DesignTime section

  cxSetResourceString(@dxSBAR_ADDEX , '添加...');
  cxSetResourceString(@dxSBAR_RENAMEEX , '重新命名...');
  cxSetResourceString(@dxSBAR_DELETE , '删除');
  cxSetResourceString(@dxSBAR_CLEAR , '清空');
  cxSetResourceString(@dxSBAR_VISIBLE , '可见的');
  cxSetResourceString(@dxSBAR_OK , '确定');
  cxSetResourceString(@dxSBAR_CANCEL , '返回');
  cxSetResourceString(@dxSBAR_SUBMENUEDITOR , '子菜单编辑...');
  cxSetResourceString(@dxSBAR_SUBMENUEDITORCAPTION , '特殊栏子菜单编辑');
  cxSetResourceString(@dxSBAR_INSERTEX , '插入...');

  cxSetResourceString(@dxSBAR_MOVEUP , '上移');
  cxSetResourceString(@dxSBAR_MOVEDOWN , '下移');
  cxSetResourceString(@dxSBAR_POPUPMENUEDITOR , '快捷菜单编辑...');
  cxSetResourceString(@dxSBAR_TABSHEET1 , ' 工具栏 ');
  cxSetResourceString(@dxSBAR_TABSHEET2 , ' 命令 ');
  cxSetResourceString(@dxSBAR_TABSHEET3 , ' 选项 ');
  cxSetResourceString(@dxSBAR_TOOLBARS , '工具栏(&A):');
  cxSetResourceString(@dxSBAR_TNEW , '新的(&N)...');
  cxSetResourceString(@dxSBAR_TRENAME , '重命名(&E)...');
  cxSetResourceString(@dxSBAR_TDELETE , '删除(&D)');
  cxSetResourceString(@dxSBAR_TRESET , '重新设置(&R)...');
  cxSetResourceString(@dxSBAR_CLOSE , '关闭');
  cxSetResourceString(@dxSBAR_CAPTION , '定制');
  cxSetResourceString(@dxSBAR_CATEGORIES , '分类(&G):');
  cxSetResourceString(@dxSBAR_COMMANDS , '命令(&D):');
  cxSetResourceString(@dxSBAR_DESCRIPTION , '描述  ');

  cxSetResourceString(@dxSBAR_MDIMINIMIZE , '最小化窗口');
  cxSetResourceString(@dxSBAR_MDIRESTORE , '恢复窗口');
  cxSetResourceString(@dxSBAR_MDICLOSE , '关闭窗口');
  cxSetResourceString(@dxSBAR_CUSTOMIZE , '定制(&C)...');
  cxSetResourceString(@dxSBAR_ADDREMOVEBUTTONS , '添加或删除一个按钮(&A)');
  cxSetResourceString(@dxSBAR_MOREBUTTONS , '更多的按钮');
  cxSetResourceString(@dxSBAR_RESETTOOLBAR , '重新设置工具栏(&R)');
  cxSetResourceString(@dxSBAR_EXPAND , '扩展 (Ctrl-Down)');
  cxSetResourceString(@dxSBAR_DRAGTOMAKEMENUFLOAT , '拖曳使菜单在窗口漂浮');

  cxSetResourceString(@dxSBAR_MORECOMMANDS , '更多的命令(&M)...');
  cxSetResourceString(@dxSBAR_SHOWBELOWRIBBON , '在Ribbon下方显示快速访问工具条(&S)');
  cxSetResourceString(@dxSBAR_SHOWABOVERIBBON , '在Ribbon上方显示快速访问工具条(&S)');
  cxSetResourceString(@dxSBAR_MINIMIZERIBBON , '最小化Ribbon(&n)');
  cxSetResourceString(@dxSBAR_ADDTOQAT , '添加快速访问工具条(&A)');
  cxSetResourceString(@dxSBAR_ADDTOQATITEMNAME , '添加%s到快速访问工具条(&A)');
  cxSetResourceString(@dxSBAR_REMOVEFROMQAT , '从快速访问工具条中移出(&R)');
  cxSetResourceString(@dxSBAR_CUSTOMIZEQAT , '自定义快速访问工具条');
  cxSetResourceString(@dxSBAR_ADDGALLERYNAME , '图库');
  //Gallery');
  {
  cxSetResourceString(@dxSBAR_SHOWALLGALLERYGROUPS , '显示所有组');
  //Show all groups');
  cxSetResourceString(@dxSBAR_HIDEALLGALLERYGROUPS , '隐藏所有组');
  //Hide all groups');
  cxSetResourceString(@dxSBAR_CLEARGALLERYFILTER , '清除条件');
  //Clear filter');
  cxSetResourceString(@dxSBAR_GALLERYEMPTYFILTERCAPTION , '<空>');
  //<empty>');
  }
  cxSetResourceString(@dxSBAR_TOOLBARNEWNAME  , '定制 ');
  cxSetResourceString(@dxSBAR_CATEGORYADD  , '添加种类');
  cxSetResourceString(@dxSBAR_CATEGORYINSERT  , '添加种类');
  cxSetResourceString(@dxSBAR_CATEGORYRENAME  , '种类重新命名');
  cxSetResourceString(@dxSBAR_TOOLBARADD  , '添加工具栏');
  cxSetResourceString(@dxSBAR_TOOLBARRENAME  , '工具栏重新命名');
  cxSetResourceString(@dxSBAR_CATEGORYNAME  , '种类名称(&C):');
  cxSetResourceString(@dxSBAR_TOOLBARNAME  , '工具栏名称(&T):');
  cxSetResourceString(@dxSBAR_CUSTOMIZINGFORM , '定制形状...');

  cxSetResourceString(@dxSBAR_MODIFY , '... 修改');
  cxSetResourceString(@dxSBAR_PERSMENUSANDTOOLBARS , '个性化菜单和工具栏  ');
  cxSetResourceString(@dxSBAR_MENUSSHOWRECENTITEMS , '在菜单显示最近被使用的最初命令(&N)');
  cxSetResourceString(@dxSBAR_SHOWFULLMENUSAFTERDELAY , '在暂短延迟后显示完整菜单(&U)');
  cxSetResourceString(@dxSBAR_RESETUSAGEDATA , '重新设置使用的数据(&R)');

  cxSetResourceString(@dxSBAR_OTHEROPTIONS , '其它  ');
  cxSetResourceString(@dxSBAR_LARGEICONS , '大图标(&L)');
  cxSetResourceString(@dxSBAR_HINTOPT1 , '在工具栏上显示工具提示(&T)');
  cxSetResourceString(@dxSBAR_HINTOPT2 , '在工具提示上显示快捷键(&H)');
  cxSetResourceString(@dxSBAR_MENUANIMATIONS , '动态菜单(&M):');
  cxSetResourceString(@dxSBAR_MENUANIM1 , '(空)');
  cxSetResourceString(@dxSBAR_MENUANIM2 , '随意');
  cxSetResourceString(@dxSBAR_MENUANIM3 , '伸展');
  cxSetResourceString(@dxSBAR_MENUANIM4 , '滑动');
  cxSetResourceString(@dxSBAR_MENUANIM5 , '淡出');

  cxSetResourceString(@dxSBAR_CANTFINDBARMANAGERFORSTATUSBAR , 'A bar manager cannot be found for the status bar');

  cxSetResourceString(@dxSBAR_BUTTONDEFAULTACTIONDESCRIPTION , 'Press');

  cxSetResourceString(@dxSBAR_GDIPLUSNEEDED , '%s requires the Microsoft GDI+ library to be installed');
  cxSetResourceString(@dxSBAR_RIBBONMORETHANONE  , 'There should be only one %s instance on the form');
  cxSetResourceString(@dxSBAR_RIBBONBADOWNER , '%s should have TCustomForm as its Owner');
  cxSetResourceString(@dxSBAR_RIBBONBADPARENT , '%s should have TCustomForm as its Parent');
  cxSetResourceString(@dxSBAR_RIBBONADDTAB , '添加 Tab');
  cxSetResourceString(@dxSBAR_RIBBONDELETETAB , '删除 Tab');
  cxSetResourceString(@dxSBAR_RIBBONADDEMPTYGROUP , '加入空组');
  //Add Empty Group');
  cxSetResourceString(@dxSBAR_RIBBONADDGROUPWITHTOOLBAR , '在Toolbar中加入组');
  // Add Group With Toolbar');
  cxSetResourceString(@dxSBAR_RIBBONDELETEGROUP , '删除 Group');

  cxSetResourceString(@dxSBAR_ACCESSIBILITY_RIBBONNAME , 'Ribbon');
  cxSetResourceString(@dxSBAR_ACCESSIBILITY_RIBBONTABCOLLECTIONNAME , 'Ribbon Tabs');


  cxSetResourceString(@scxGridChartCategoriesDisplayText, '数据');

  cxSetResourceString(@scxGridChartValueHintFormat,'%s for %s is %s');  // series display text, category, value
  cxSetResourceString(@scxGridChartPercentValueTickMarkLabelFormat,'0%');

  cxSetResourceString(@scxGridChartToolBoxDataLevels,'数据层:');
  cxSetResourceString(@scxGridChartToolBoxDataLevelSelectValue,'选择的值');
  cxSetResourceString(@scxGridChartToolBoxCustomizeButtonCaption,'选择样式');

  cxSetResourceString(@scxGridChartNoneDiagramDisplayText,'没有图表');
  cxSetResourceString(@scxGridChartColumnDiagramDisplayText,'柱形图');
  cxSetResourceString(@scxGridChartBarDiagramDisplayText,'条形图');
  cxSetResourceString(@scxGridChartLineDiagramDisplayText,'曲线图');
  cxSetResourceString(@scxGridChartAreaDiagramDisplayText,'面积图');
  cxSetResourceString(@scxGridChartPieDiagramDisplayText,'饼图');

  cxSetResourceString(@scxGridChartCustomizationFormSeriesPageCaption , '系数');
  cxSetResourceString(@scxGridChartCustomizationFormSortBySeries , '分类:');
  cxSetResourceString(@scxGridChartCustomizationFormNoSortedSeries , '<不选择>');
  cxSetResourceString(@scxGridChartCustomizationFormDataGroupsPageCaption , '数据分组');
  cxSetResourceString(@scxGridChartCustomizationFormOptionsPageCaption , '选项');

  cxSetResourceString(@scxGridChartLegend , '图例');
  cxSetResourceString(@scxGridChartLegendKeyBorder , '调节边界值'); //'Key Border';
  cxSetResourceString(@scxGridChartPosition , '位置');
  cxSetResourceString(@scxGridChartPositionDefault , '默认');
  cxSetResourceString(@scxGridChartPositionNone , '无');
  cxSetResourceString(@scxGridChartPositionLeft , '左');
  cxSetResourceString(@scxGridChartPositionTop , '上');
  cxSetResourceString(@scxGridChartPositionRight , '右');
  cxSetResourceString(@scxGridChartPositionBottom , '下');
  cxSetResourceString(@scxGridChartAlignment , '对齐');
  cxSetResourceString(@scxGridChartAlignmentDefault , '默认');
  cxSetResourceString(@scxGridChartAlignmentStart , '开始');
  cxSetResourceString(@scxGridChartAlignmentCenter , '中间');
  cxSetResourceString(@scxGridChartAlignmentEnd , '结尾');
  cxSetResourceString(@scxGridChartOrientation , '方向');
  cxSetResourceString(@scxGridChartOrientationDefault , '默认');
  cxSetResourceString(@scxGridChartOrientationHorizontal , '水平');
  cxSetResourceString(@scxGridChartOrientationVertical , '垂直');
  cxSetResourceString(@scxGridChartBorder , '边框');
  cxSetResourceString(@scxGridChartTitle , '标题');
  cxSetResourceString(@scxGridChartToolBox,'工具栏');
  cxSetResourceString(@scxGridChartDiagramSelector , '图表样式选择器');
  cxSetResourceString(@scxGridChartOther , '其它');
  cxSetResourceString(@scxGridChartValueHints , '提示值');

//------------------------------------------------------------------------------
// dxNavBarConsts
// Office11Views popup menu captions
//------------------------------------------------------------------------------
  cxSetResourceString(@sdxNavBarOffice11ShowMoreButtons , '显示更多按钮...(&M)');
  //Show &More Buttons
  cxSetResourceString(@sdxNavBarOffice11ShowFewerButtons , '显示较少按钮...(&F)');
  //Show &Fewer Buttons
  cxSetResourceString(@sdxNavBarOffice11AddRemoveButtons , '添加删除按钮...(&A)');
  //&Add or Remove Buttons
end;

initialization
  ApplyChineseResourceString;
  //启用中文
end.

