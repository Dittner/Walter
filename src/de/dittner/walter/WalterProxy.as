package de.dittner.walter {
import de.dittner.walter.message.IMessageSender;
import de.dittner.walter.message.WalterMessage;

import flash.events.EventDispatcher;

use namespace walter_namespace;

public class WalterProxy extends EventDispatcher {
	private static var proxiesNum:uint = 0;
	public function WalterProxy() {
		super();
		_uid = "walter" + (proxiesNum++);
	}

	private var _uid:String;
	walter_namespace function get uid():String {return _uid;}
	walter_namespace var proxyHandlersHash:Object = {};

	walter_namespace static function get walter():Walter {return Walter.instance;}
	walter_namespace static function get proxyMessageSender():IMessageSender {return walter.proxyMessageSender;}

	public function listenProxy(proxy:WalterProxy, msgKey:String, handler:Function):void {
		if (!proxyHandlersHash[proxy.uid]) proxyHandlersHash[proxy.uid] = {};
		var handlerHash:Object = proxyHandlersHash[proxy.uid];
		handlerHash[msgKey] = handler;
		proxyMessageSender.listen(proxy.uid, msgKey, handler);
	}

	public function removeProxyListener(proxy:WalterProxy, msgKey:String):void {
		if (proxyHandlersHash[proxy.uid]) {
			var handlerHash:Object = proxyHandlersHash[proxy.uid];
			if (handlerHash[msgKey] != null) {
				proxyMessageSender.removeListener(proxy.uid, msgKey, handlerHash[msgKey]);
				delete handlerHash[msgKey];
			}
		}
	}

	public function removeAllListeners():void {
		for (var proxyUID:String in proxyHandlersHash) {
			var handlerHash:Object = proxyHandlersHash[proxyUID];
			for (var msgKey:String in handlerHash)
				proxyMessageSender.removeListener(proxyUID, msgKey, handlerHash[msgKey]);
		}
		proxyHandlersHash = {};
	}

	public function sendMessage(msgKey:String, data:Object = null):void {
		proxyMessageSender.sendMessage(uid, new WalterMessage(msgKey, data));
	}

	walter_namespace function activating():void {
		activate();
	}

	walter_namespace function deactivating():void {
		proxyMessageSender.removeDispatcher(uid);
		removeAllListeners();
		deactivate();
		walter.injector.uninject(this);
	}

	//abstract
	protected function activate():void {}
	//abstract
	protected function deactivate():void {}

}
}