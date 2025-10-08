from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.http.response import HttpResponse

def home(request):
    return render(request, "index.html")