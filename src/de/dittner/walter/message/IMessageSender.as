package de.dittner.walter.message {
public interface IMessageSender {
	function listen(dispatcherUID:String, msgKey:String, handler:Function):void;
	function removeListener(dispatcherUID:String, msgKey:String, handler:Function):void;
	function removeDispatcher(dispatcherUID:String):void
	function sendMessage(dispatcherUID:String, msg:WalterMessage):void;
}
}
