# 管理类APP

> 主要用于企业内生产的APP，用于内网环境，因此配置了网络设置，可以定义请求的IP和端口。

> RSA公钥私钥未上传, 执行时需要在`assets/pki`文件夹下创建`public.pem` 和 `private.pem` 文件，没有`pki`文件夹创建对应的文件夹。

## 安卓打包

> `keytool -genkey -alias flutterDemo -keyalg RSA -keysize 1024 -validity 10000 -keystore /Users/xx/tomcat.keystore -keypass 123456 -storepass 123456 -dname "CN=xingming,OU=danwei,O=zuzhi,L=shi,ST=sheng,C=CN"`

> 将`tomcat.keystore`文件移动到Android文件夹下，并创建`key.properties`文件，并录入文件
```
storePassword=123456<上一步骤中的密码>
keyPassword=123456<上一步骤中的密码>
keyAlias=flutterDemo<key>
storeFile=/Users/xx/tomcat.keystore<密钥库文件位置>
```

> `app/build.gradle`中增加如下，具体参考本项目

```
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
keystoreProperties.load(new FileInputStream(keystorePropertiesFile))



signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile file(keystoreProperties['storeFile'])
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        // TODO: Add your own signing config for the release build.
        // Signing with the debug keys for now, so `flutter run --release` works.
        // signingConfig signingConfigs.debug
        signingConfig signingConfigs.release
    }
}
```