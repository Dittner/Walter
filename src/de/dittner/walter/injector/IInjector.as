package de.dittner.walter.injector {
public interface IInjector {
	function injectPendingProxies():void;
	function inject(obj:Object):void;
	function uninject(obj:Object):void;
	function hasInjectDeclaration(obj:Object, injectedProp:String):Boolean;
}
}
