FROM alpine:3.8
LABEL maintainer="Stille <stille@ioiox.com>"

# 使用构建参数支持多架构构建
ARG TARGETARCH
ARG TARGETVARIANT
ENV VERSION=0.28.2
ENV TZ=Asia/Shanghai

WORKDIR /

RUN apk add --no-cache tzdata wget \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

# 多架构支持
RUN case "${TARGETARCH}" in \
      "amd64") PLATFORM="amd64" ;; \
      "arm64") PLATFORM="arm64" ;; \
      "arm") \
        case "${TARGETVARIANT}" in \
          "v7") PLATFORM="arm" ;; \
          *) PLATFORM="arm" ;; \
        esac ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac \
    && echo "Building for platform: ${PLATFORM}" \
    && wget --no-check-certificate -q -O frp.tar.gz https://github.com/fatedier/frp/releases/download/v${VERSION}/frp_${VERSION}_linux_${PLATFORM}.tar.gz \
    && tar xzf frp.tar.gz \
    && cd frp_${VERSION}_linux_${PLATFORM} \
    && mkdir -p /frp \
    && mv frps /frp/ \
    # 创建默认配置目录
    && mkdir -p /frp/default-config \
    && mv frps.ini /frp/default-config/frps.ini \
    && cd / \
    && rm -rf frp_${VERSION}_linux_${PLATFORM} frp.tar.gz \
    && apk del wget

# 设置可执行权限
RUN chmod +x /frp/frps

# 创建默认 hosts 条目文件
RUN echo "8.8.8.8 dns.google" > /frp/default-config/custom-hosts

# 创建配置目录（确保存在）
RUN mkdir -p /frp/config

# 复制初始化脚本
COPY init.sh /init.sh
RUN chmod +x /init.sh

# 暴露配置目录用于映射
VOLUME /frp/config

CMD ["/init.sh"]
