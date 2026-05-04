FROM golang:1.26-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN GOOS=linux GOARCH=amd64 go build -o app

FROM public.ecr.aws/lambda/provided:al2023
COPY --from=build /src/app ./app
ENTRYPOINT [ "./app" ]
