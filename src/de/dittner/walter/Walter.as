package de.dittner.walter {
import de.dittner.walter.injector.Injector;
import de.dittner.walter.message.IMessageSender;
import de.dittner.walter.message.MessageSender;

use namespace walter_namespace;

public class Walter {

	private static var _instance:Walter;
	public static function get instance():Walter {return _instance;}

	public function Walter() {
		if (_instance) throw new Error("Duplicate Walter!");
		_instance = this;
		injector = new Injector(this);
		proxyMessageSender = new MessageSender();
	}

	//----------------------------------------------------------------------------------------------
	//
	//  Variables
	//
	//----------------------------------------------------------------------------------------------

	public var injector:Injector;
	walter_namespace var proxyHash:Object = {};
	walter_namespace var pendingInjectProxies:Array = [];
	walter_namespace var proxyMessageSender:IMessageSender;

	//----------------------------------------------------------------------------------------------
	//
	//  Properties
	//
	//----------------------------------------------------------------------------------------------

	//--------------------------------------
	//  hasProxy
	//--------------------------------------
	public function hasProxy(id:String):Boolean {return proxyHash[id] != null;}

	//--------------------------------------
	//  getProxy
	//--------------------------------------
	public function getProxy(id:String):WalterProxy {return proxyHash[id];}

	//----------------------------------------------------------------------------------------------
	//
	//  Methods
	//
	//----------------------------------------------------------------------------------------------

	public function registerProxy(proxyName:String, proxy:WalterProxy):void {
		if (proxyHash[proxyName]) throw new Error("duplicate proxy with name: " + proxyName);
		proxyHash[proxyName] = proxy;
		pendingInjectProxies.push(proxy);
		injector.injectPendingProxies();
	}

	public function destroy():void {
		for (var proxyName:String in proxyHash) proxyHash[proxyName].deactivating();
		proxyHash = null;
		pendingInjectProxies.length = 0;
		pendingInjectProxies = null;
	}

}
}
