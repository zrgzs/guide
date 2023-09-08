---
title: 'text_plain' WebClient
date: 2023-09-07 17:59:14
categories:
- java项目合集
- 小昭
author: lx0815
comment: false
---

```java
2023-03-18 19:35:54.845 [http-nio-8080-exec-1] ERROR org.apache.catalina.core.ContainerBase.[Tomcat].[localhost].[/].[dispatcherServlet] -
                Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed; nested exception is org.springframework.web.reactive.function.client.WebClientResponseException: 200 OK from GET https://api.weixin.qq.com/sns/jscode2session?appid=wxaf4b3d349ec6a25a&secret=b12ba4742de769a5fc808e4927d708bb&js_code=0037Cw000fQaDP1vN9300Fv60i27Cw0l&grant_type=authorization_code; nested exception is org.springframework.web.reactive.function.UnsupportedMediaTypeException: Content type 'text/plain' not supported for bodyType=com.sgqn.healthmanagementserver.model.WechatLoginResponse] with root cause
org.springframework.web.reactive.function.UnsupportedMediaTypeException: Content type 'text/plain' not supported for bodyType=com.sgqn.healthmanagementserver.model.WechatLoginResponse
	at org.springframework.web.reactive.function.BodyExtractors.lambda$readWithMessageReaders$12(BodyExtractors.java:201)
	Suppressed: reactor.core.publisher.FluxOnAssembly$OnAssemblyException: 
Error has been observed at the following site(s):
	*__checkpoint ⇢ Body from GET https://api.weixin.qq.com/sns/jscode2session?appid=wxaf4b3d349ec6a25a&secret=b12ba4742de769a5fc808e4927d708bb&js_code=0037Cw000fQaDP1vN9300Fv60i27Cw0l&grant_type=authorization_code [DefaultClientResponse]
Original Stack Trace:
		at org.springframework.web.reactive.function.BodyExtractors.lambda$readWithMessageReaders$12(BodyExtractors.java:201)
		at java.util.Optional.orElseGet(Optional.java:267)
		at org.springframework.web.reactive.function.BodyExtractors.readWithMessageReaders(BodyExtractors.java:197)
		at org.springframework.web.reactive.function.BodyExtractors.lambda$toMono$2(BodyExtractors.java:85)
		at org.springframework.web.reactive.function.client.DefaultClientResponse.body(DefaultClientResponse.java:131)
		at org.springframework.web.reactive.function.client.DefaultClientResponse.bodyToMono(DefaultClientResponse.java:146)
		at org.springframework.web.reactive.function.client.DefaultWebClient$DefaultResponseSpec.lambda$bodyToMono$2(DefaultWebClient.java:543)
		at reactor.core.publisher.MonoFlatMap$FlatMapMain.onNext(MonoFlatMap.java:125)
		at reactor.core.publisher.FluxSwitchIfEmpty$SwitchIfEmptySubscriber.onNext(FluxSwitchIfEmpty.java:74)
		at reactor.core.publisher.FluxMap$MapSubscriber.onNext(FluxMap.java:122)
		at reactor.core.publisher.FluxOnErrorResume$ResumeSubscriber.onNext(FluxOnErrorResume.java:79)
		at reactor.core.publisher.FluxPeek$PeekSubscriber.onNext(FluxPeek.java:200)
		at reactor.core.publisher.FluxPeek$PeekSubscriber.onNext(FluxPeek.java:200)
		at reactor.core.publisher.FluxPeek$PeekSubscriber.onNext(FluxPeek.java:200)
		at reactor.core.publisher.MonoNext$NextSubscriber.onNext(MonoNext.java:82)
		at reactor.core.publisher.MonoFlatMapMany$FlatMapManyInner.onNext(MonoFlatMapMany.java:250)
		at reactor.core.publisher.FluxContextWrite$ContextWriteSubscriber.onNext(FluxContextWrite.java:107)
		at reactor.core.publisher.Operators$ScalarSubscription.request(Operators.java:2400)
		at reactor.core.publisher.FluxContextWrite$ContextWriteSubscriber.request(FluxContextWrite.java:136)
		at reactor.core.publisher.MonoFlatMapMany$FlatMapManyMain.onSubscribeInner(MonoFlatMapMany.java:150)
		at reactor.core.publisher.MonoFlatMapMany$FlatMapManyInner.onSubscribe(MonoFlatMapMany.java:245)
		at reactor.core.publisher.FluxContextWrite$ContextWriteSubscriber.onSubscribe(FluxContextWrite.java:101)
		at reactor.core.publisher.FluxJust.subscribe(FluxJust.java:68)
		at reactor.core.publisher.Flux.subscribe(Flux.java:8642)
		at reactor.core.publisher.MonoFlatMapMany$FlatMapManyMain.onNext(MonoFlatMapMany.java:195)
		at reactor.core.publisher.SerializedSubscriber.onNext(SerializedSubscriber.java:99)
		at reactor.core.publisher.FluxRetryWhen$RetryWhenMainSubscriber.onNext(FluxRetryWhen.java:174)
		at reactor.core.publisher.MonoCreate$DefaultMonoSink.success(MonoCreate.java:172)
		at reactor.netty.http.client.HttpClientConnect$HttpIOHandlerObserver.onStateChange(HttpClientConnect.java:435)
		at reactor.netty.ReactorNetty$CompositeConnectionObserver.onStateChange(ReactorNetty.java:707)
		at reactor.netty.resources.DefaultPooledConnectionProvider$DisposableAcquire.onStateChange(DefaultPooledConnectionProvider.java:193)
		at reactor.netty.resources.DefaultPooledConnectionProvider$PooledConnection.onStateChange(DefaultPooledConnectionProvider.java:454)
		at reactor.netty.http.client.HttpClientOperations.onInboundNext(HttpClientOperations.java:647)
		at reactor.netty.channel.ChannelOperationsHandler.channelRead(ChannelOperationsHandler.java:113)
		at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:444)
		at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:420)
		at io.netty.channel.AbstractChannelHandlerContext.fireChannelRead(AbstractChannelHandlerContext.java:412)
		at io.netty.handler.codec.MessageToMessageDecoder.channelRead(MessageToMessageDecoder.java:103)
		at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:444)
		at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:420)
		at io.netty.channel.AbstractChannelHandlerContext.fireChannelRead(AbstractChannelHandlerContext.java:412)
		at io.netty.channel.CombinedChannelDuplexHandler$DelegatingChannelHandlerContext.fireChannelRead(CombinedChannelDuplexHandler.java:436)
		at io.netty.handler.codec.ByteToMessageDecoder.fireChannelRead(ByteToMessageDecoder.java:346)
		at io.netty.handler.codec.ByteToMessageDecoder.fireChannelRead(ByteToMessageDecoder.java:333)
		at io.netty.handler.codec.ByteToMessageDecoder.callDecode(ByteToMessageDecoder.java:454)
		at io.netty.handler.codec.ByteToMessageDecoder.channelRead(ByteToMessageDecoder.java:290)
		at io.netty.channel.CombinedChannelDuplexHandler.channelRead(CombinedChannelDuplexHandler.java:251)
		at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:442)
		at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:420)
		at io.netty.channel.AbstractChannelHandlerContext.fireChannelRead(AbstractChannelHandlerContext.java:412)
		at io.netty.handler.ssl.SslHandler.unwrap(SslHandler.java:1382)
		at io.netty.handler.ssl.SslHandler.decodeJdkCompatible(SslHandler.java:1245)
		at io.netty.handler.ssl.SslHandler.decode(SslHandler.java:1294)
		at io.netty.handler.codec.ByteToMessageDecoder.decodeRemovalReentryProtection(ByteToMessageDecoder.java:529)
		at io.netty.handler.codec.ByteToMessageDecoder.callDecode(ByteToMessageDecoder.java:468)
		at io.netty.handler.codec.ByteToMessageDecoder.channelRead(ByteToMessageDecoder.java:290)
		at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:444)
		at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:420)
		at io.netty.channel.AbstractChannelHandlerContext.fireChannelRead(AbstractChannelHandlerContext.java:412)
		at io.netty.channel.DefaultChannelPipeline$HeadContext.channelRead(DefaultChannelPipeline.java:1410)
		at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:440)
		at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:420)
		at io.netty.channel.DefaultChannelPipeline.fireChannelRead(DefaultChannelPipeline.java:919)
		at io.netty.channel.nio.AbstractNioByteChannel$NioByteUnsafe.read(AbstractNioByteChannel.java:166)
		at io.netty.channel.nio.NioEventLoop.processSelectedKey(NioEventLoop.java:788)
		at io.netty.channel.nio.NioEventLoop.processSelectedKeysOptimized(NioEventLoop.java:724)
		at io.netty.channel.nio.NioEventLoop.processSelectedKeys(NioEventLoop.java:650)
		at io.netty.channel.nio.NioEventLoop.run(NioEventLoop.java:562)
		at io.netty.util.concurrent.SingleThreadEventExecutor$4.run(SingleThreadEventExecutor.java:997)
		at io.netty.util.internal.ThreadExecutorMap$2.run(ThreadExecutorMap.java:74)
		at io.netty.util.concurrent.FastThreadLocalRunnable.run(FastThreadLocalRunnable.java:30)
		at java.lang.Thread.run(Thread.java:750)
```

解决：[Spring reactive WebClient GET json response with Content-Type “text/plain;charset=UTF-8”](https://stackoverflow.com/questions/61257963/spring-reactive-webclient-get-json-response-with-content-type-text-plaincharse)
