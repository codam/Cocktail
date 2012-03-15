package org.intermedia.model;

import org.intermedia.model.XmlLoader;
import org.intermedia.model.ApplicationModel;

/**
 * Loads a rss feed and parses it either to a CellData or a DetailData returned to the ApplicationModel
 * 
 * @author Raphael Harmel
 */

class DataLoader 
{

	// Defines onLoad callback, called when the xml feed is loaded
	private var onCellDataLoaded : Array<CellData>->Void;
	private var onCellDetailLoaded : DetailData->Void;
	private var onLoadingError : Dynamic->Void;
	
	// online/offline switch
	private var _online:Bool;
	
	// quantity of rss items to load
	private var _itemsToLoad:Int;
	
	// page index containing _itemsToLoad items
	private var _pageIndex:Int;

	/*private function onLoadingError(unknown:Dynamic):Void
	{
		trace("error in DataLoader");
	}*/
	
	//public function new(?itemsToLoad:Int = 10, ?pageIndex:Int = 1, ?online:Bool=true)
	public function new(?online:Bool=true)
	{
		// init private attributes
		//_itemsToLoad = itemsToLoad;
		//_pageIndex = pageIndex;
		_pageIndex = 1;
		_online = online;
		
	}
	
	/**
	 * Starts loading an RSS feed, construct the URL with the right GET params to load the CellData.
	 * @param	startIndex
	 * @param	endIndex
	 * @param	?callBack
	 */
	//public function loadCellData(itemsPerPage:Int, ?pageIndex:Int=1, successCallback:Array<CellData>->Void, errorCallback:Dynamic->Void):Void
	public function loadCellData(itemsPerPage:Int, successCallback:Array<CellData>->Void, errorCallback:Dynamic->Void):Void
	{
		// set callbacks
		onCellDataLoaded = successCallback;
		onLoadingError = errorCallback;
		
		var fullUrl:String = "";
		
		// prepare online feed url
		if (_online)
		{
			fullUrl = "http://www.silexlabs.org/feed/ep_posts_small/?cat=646&format=rss2&posts_per_page=" + itemsPerPage + "&paged=" + _pageIndex;
			_pageIndex++;
		}
		// prepare local feed url
		else fullUrl = "data/silex_plugins.rss";
		
		// load xml feed
		var xmlLoader:XmlLoader = new XmlLoader(fullUrl, _online, onCellsXmlLoaded, onLoadingError);
	}
	
	/**
	 * Same as above for detail data
	 * @param	cellData
	 * @param	?callBack
	 */
	public function loadDetailData(cellData:CellData, successCallback:DetailData->Void, errorCallback:Dynamic->Void):Void
	{
		// set callbacks
		onCellDetailLoaded = successCallback;
		onLoadingError = errorCallback;
		
		// Delegate callback
		var onLoadSuccessDelegate:Xml->Void = function(xml:Xml) { onCellDetailXmlLoaded(xml, cellData); };
		
		var fullUrl:String = "";
		
		// prepare online feed url
		if (_online) fullUrl = "http://www.silexlabs.org/feed/ep_get_item_info?format=rss2&p=" + cellData.id;
		// prepare local feed url
		else fullUrl = "data/detail.rss";
		
		// load xml feed
		var xmlLoader:XmlLoader = new XmlLoader(fullUrl, _online, onLoadSuccessDelegate, onLoadingError);

	}
	
	/**
	 * cells rss loaded callback
	 * converts the xml to an Array<CellData>
	 * 
	 * @param	xml
	 */
	private function onCellsXmlLoaded(xml:Xml):Void
	{
		onCellDataLoaded(ThumbTextListRss.rss2Cells(xml));
	}	
	
	/**
	 * cell detail rss loaded callback
	 * converts the xml to DetailData
	 * 
	 * @param	xml
	 */
	private function onCellDetailXmlLoaded(xml:Xml,cellData:CellData):Void
	{
		onCellDetailLoaded(CellDetailsRss.rss2CellDetail(xml,cellData));
	}
	
}
