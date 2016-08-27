package de.dittner.walter.message {

public class MessageSender implements IMessageSender {
	public function MessageSender() {}

	private var dispatcherHash:Object = {};

	public function listen(dispatcherUID:String, msgKey:String, handler:Function):void {
		if (!dispatcherHash[dispatcherUID]) dispatcherHash[dispatcherUID] = {};
		var handlerHash:Object = dispatcherHash[dispatcherUID];
		if (!handlerHash[msgKey]) handlerHash[msgKey] = [];
		handlerHash[msgKey].push(handler);
	}

	public function removeListener(dispatcherUID:String, msgKey:String, handler:Function):void {
		var handlerHash:Object = dispatcherHash[dispatcherUID];
		if (handlerHash && handlerHash[msgKey]) {
			var handlers:Array = handlerHash[msgKey];
			for (var i:int = 0; i < handlers.length; i++) {
				if (handlers[i] == handler) {
					handlers.splice(i, 1);
					break;
				}
			}
		}
	}

	public function removeDispatcher(dispatcherUID:String):void {
		delete dispatcherHash[dispatcherUID];
	}

	public function sendMessage(dispatcherUID:String, msg:WalterMessage):void {
		var handlerHash:Object = dispatcherHash[dispatcherUID];
		if (handlerHash && handlerHash[msg.key]) {
			for each(var handler:Function in handlerHash[msg.key]) handler(msg);
		}
	}
}
}
