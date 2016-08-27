package de.dittner.walter.injector {
import de.dittner.async.utils.invalidateOf;
import de.dittner.walter.Walter;
import de.dittner.walter.WalterProxy;
import de.dittner.walter.walter_namespace;

import flash.utils.describeType;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

use namespace walter_namespace;

public class Injector implements IInjector {
	public function Injector(walter:Walter) {
		this.walter = walter;
	}

	private var walter:Walter;
	private static const classInjectionPropHash:Object = {};

	public function injectPendingProxies():void {
		var injectionComplete:Boolean;
		for (var i:int = 0; i < walter.pendingInjectProxies.length; i++) {
			var proxy:WalterProxy = walter.pendingInjectProxies[i];
			injectionComplete = true;
			var props:Array = getInjectedProps(proxy);
			for each (var prop:String in props) {
				if (proxy[prop] == null) {
					if (walter.proxyHash[prop]) proxy[prop] = walter.proxyHash[prop];
					else if (walter.hasProxy(prop)) proxy[prop] = walter.getProxy(prop);
					else {
						injectionComplete = false;
						break;
					}
				}
			}
			if (injectionComplete) {
				walter.pendingInjectProxies.splice(i, 1);
				i--;
				invalidateOf(proxy.activating);
			}
		}
	}

	public function inject(obj:Object):void {
		var props:Array = getInjectedProps(obj);
		for each (var prop:String in props) {
			if (obj[prop] == null) {
				if (walter.proxyHash[prop]) obj[prop] = walter.proxyHash[prop];
				else if (walter.hasProxy(prop)) obj[prop] = walter.getProxy(prop);
			}
		}
	}

	public function uninject(obj:Object):void {
		var props:Array = getInjectedProps(obj);
		for each (var prop:String in props) {
			obj[prop] = null;
		}
	}

	public function hasInjectDeclaration(obj:Object, injectedProp:String):Boolean {
		var props:Array = getInjectedProps(obj);
		for each(var prop:String in props)
			if (prop == injectedProp) return true;
		return false;
	}

	protected function getInjectedProps(obj:Object):Array {
		var className:Class = Class(getDefinitionByName(getQualifiedClassName(obj)));
		if (classInjectionPropHash[className]) return classInjectionPropHash[className];

		var props:Array = [];
		var classDescription:XML = describeType(className);
		var nodesList:XMLList = classDescription.factory.*;
		var nodeCount:int = nodesList.length();
		for (var i:int = 0; i < nodeCount; i++) {
			var node:XML = nodesList[i];
			var nodeName:String = node.name();
			if (nodeName == "variable" || nodeName == "accessor") {
				var metadataList:XMLList = node.metadata;
				var metadataCount:int = metadataList.length();
				for (var j:int = 0; j < metadataCount; j++) {
					nodeName = metadataList[j].@name;
					if (nodeName == "Inject") {
						props.push(node.@name.toString());
					}
				}
			}
		}

		classInjectionPropHash[className] = props;
		return props;
	}
}
}
